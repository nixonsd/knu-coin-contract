import * as dotenv from 'dotenv';
dotenv.config();

export default [
  Number(process.env.TEACHER_TELEGRAM_ID as string), 
  Number(process.env.TEACHER_ARRANGEMENT_LIMIT as string), 
  process.env.CONTRACT_NAME as string, 
  process.env.CONTRACT_SYMBOL as string,
]; 