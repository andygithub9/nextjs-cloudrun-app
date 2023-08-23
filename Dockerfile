# ref: https://ithelp.ithome.com.tw/articles/10238415
# ref: https://www.youtube.com/watch?v=IjUnQ9kMnVo
# image 大小 node:18 > node:18-slim > node:18-alpine ， node:18-alpine bild 出來的 image 是最小的，通常會使用 alpine 版本的
# base image
FROM node:18-alpine

# WORKDIR 指令為 Dockerfile 中設置工作目錄，之後的指令都在此工作目錄上運行。你可以想像為 cd /usr/app
WORKDIR /usr/app

# https://stackoverflow.com/questions/51066146/what-is-the-point-of-workdir-on-dockerfile
# COPY [--chown=<user>:<group>] <src>... <dest>
# 從<src>複製新文件，目錄或遠程文件URL，並將它們添加到映像的文件系統中的路徑<dest>處。
COPY . .

# https://stackoverflow.com/questions/60065865/is-there-a-way-of-making-npm-ci-install-devdependencies-or-npm-install-not
# If you have package-lock.json, speed your build by 'npm ci'
# With the --production flag npm will not install modules listed in devDependencies.
RUN npm ci --only=production

RUN npm run build

# RUN 和 CMD 的區別
# RUN 指令：在映像建構過程中執行指定的命令，可以用來安裝軟體、設定環境、複製檔案等。每一個 RUN 指令都會在映像的新一層上執行，這些變更都會被記錄下來，但在容器執行時並不會立即生效。例如，你可以使用 RUN npm install 來在映像中安裝應用程式的相依套件。
# CMD 指令：在容器啟動時執行指定的命令。這個命令會成為容器的預設執行命令，當你運行容器時，Docker 會自動執行該指令。例如，你可以使用 CMD [ "npm", "start" ] 來在容器啟動時運行 Next.js 應用程式。
CMD ["npm", "start"]