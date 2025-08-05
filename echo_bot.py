import logging
import os
import asyncio
from aiogram import Bot, Dispatcher, types
from aiogram.types import Message
from dotenv import load_dotenv

load_dotenv()


Token = os.getenv("TELEGRAM_BOT_TOKEN")

logging.basicConfig(level=logging.INFO)

bot = Bot(token=Token)
dp = Dispatcher()

@dp.message()
async def echo(message: Message):
    await message.answer(message.text)

async def main():
    await bot.delete_webhook(drop_pending_updates=True)
    await dp.start_polling(bot)

if __name__ == '__main__':
    asyncio.run(main())
