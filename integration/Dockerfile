# Образ на основе node:12
FROM node:12

# Создание директории приложения
WORKDIR /usr/src/app

# Установка зависимостей

# Символ астериск ("*") используется для того чтобы 
# скопировать оба файла: package.json и package-lock.json
COPY package*.json ./

RUN npm install

# Копируем исходный код
COPY . .

# Открытие портов
EXPOSE 8081

# Инструкция для запуска
CMD [ "node", "integration.js" ]