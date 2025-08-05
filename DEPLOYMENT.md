# Документация по развертыванию проекта Telegram-бота с использованием Terraform, Ansible и Docker

## 1. Предварительные требования
- Аккаунт Google Cloud Platform (GCP)
- Локально установленные: Terraform, Ansible, Docker, Python 3.12+
- Аккаунты DockerHub и Telegram Bot
- SSH-ключи для доступа к серверу

## 2. Создание сервисного аккаунта GCP и получение credentials.json
1. Перейдите в Google Cloud Console → IAM и администрирование → Сервисные аккаунты
2. Создайте сервисный аккаунт, выдайте ему роль `Editor` или `Compute Admin`
3. На вкладке "Ключи" создайте новый ключ в формате JSON и скачайте его
4. Сохраните файл, путь до него укажите в `terraform.tfvars` (переменная `credentials_json`)

## 3. Настройка переменных Terraform
- Откройте `infra/terraform/terraform.tfvars` и заполните все переменные согласно вашему проекту и инфраструктуре

## 4. Развертывание инфраструктуры через Terraform
```sh
cd infra/terraform
terraform init
terraform apply
```
- После успешного применения получите внешний IP вашей ВМ (output `external_ip`)

## 5. Настройка Ansible
- В файле `infra/ansible/inventory` укажите внешний IP вашей ВМ
- В файле `infra/ansible/ansible.cfg` настройте путь к inventory и параметры подключения (например, user, ключ)

## 6. Роли Ansible
- **ssh**: копирует публичный ключ на сервер
- **dependencies**: устанавливает Docker и docker-compose
- **docker**: копирует docker-compose.yml и Dockerfile, запускает контейнер
- **bot**: копирует исходный код бота и .env, перезапускает контейнер

## 7. Пример структуры inventory
```
[all]
<EXTERNAL_IP> ansible_user=<USER> ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

## 8. Запуск Ansible
```sh
cd infra/ansible
ansible-playbook playbook.yml
```

## 9. CI/CD (GitHub Actions)
- При пуше в main происходит:
  - Проверка кода (eslint)
  - Сборка и публикация Docker-образа
  - Деплой на сервер через SSH
  - Уведомления в Telegram

## 10. Переменные окружения
- Создайте файл `.env` с переменной `TELEGRAM_BOT_TOKEN`

## 11. Пример .env
```
TELEGRAM_BOT_TOKEN=ваш_токен_бота
```

## 12. Проверка
- После деплоя бот должен быть доступен в Telegram

---

# Описание ролей Ansible

## 1. ssh (infra/ansible/roles/ssh/tasks/main.yml)
```yaml
- name: Add SSH key
  authorized_key:
    user: "{{ ansible_user }}"
    state: present
    key: "{{ lookup('file', '~/.ssh/id_ed25519.pub') }}"
```

## 2. dependencies (infra/ansible/roles/dependencies/tasks/main.yml)
```yaml
- name: Install required packages
  apt:
    name:
      - docker.io
      - docker-compose
    state: present
    update_cache: yes

- name: Add user to docker group
  user:
    name: "{{ ansible_user }}"
    groups: docker
    append: yes
```

## 3. docker (infra/ansible/roles/docker/tasks/main.yml)
```yaml
- name: Copy docker-compose.yml
  copy:
    src: ../../../../Docker-compose.yml
    dest: "{{ bot_dir }}/docker-compose.yml"

- name: Copy Dockerfile
  copy:
    src: ../../../../Dockerfile
    dest: "{{ bot_dir }}/Dockerfile"
```

## 4. bot (infra/ansible/roles/bot/tasks/main.yml)
```yaml
- name: Copy bot source code
  synchronize:
    src: ../../../../
    dest: "{{ bot_dir }}"
    rsync_opts:
      - "--exclude=.git"
      - "--exclude=infra"
      - "--exclude=.github"

- name: Copy .env file
  copy:
    src: ../../../../.env
    dest: "{{ bot_dir }}/.env"

- name: Restart bot container
  shell: |
    cd {{ bot_dir }}
    docker compose down || true
    docker compose up -d --build
```

---

# Итог
- После выполнения всех шагов бот будет развернут на сервере, обновляться через CI/CD и управляться через Docker.
- Для обновления кода достаточно сделать push в main.
