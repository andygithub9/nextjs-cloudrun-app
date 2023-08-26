# Add Dockerfile

see Dockerfile

# CloudRun 需要在 package.json 的 scripts 的 start 添加 -p $PORT

CloudRun 需要在 package.json 的 scripts 的 start 添加 -p $PORT ，  
這樣就能指定 next start 的 port  
package.json

```json
{
  "scripts": {
    "start": "next start -p $PORT"
  }
}
```

如果我們 run `npm run start 3115` 就會在 3115 port 執行 next start

# Add .dockerignore

see .dockerignore

# build docker image

`docker build . -t nextjs-cloudrun-app:latest`

1. docker build：這是 Docker 命令的一部分，用來執行映像的建構過程。

2. .：這個句點表示當前目錄，它指定了 Docker 建構上下文的路徑。Docker 建構上下文包括了在此路徑下的所有文件和子目錄。這些文件將被傳送給 Docker 引擎，並被用於建構映像。在這個例子中，建構上下文是當前目錄。

3. -t nextjs-cloudrun-app:latest：這部分指定了映像的標籤（tag）。標籤是用來標識映像的一個可選的、易於辨識的名稱。在這個例子中，-t 表示指定標籤，nextjs-cloudrun-app 是映像的名稱，latest 是標籤名稱。這表示建構的映像將被命名為 nextjs-cloudrun-app，並被標記為 latest 版本。

# Docker commands

## List images

syntax: `docker image ls [OPTIONS] [REPOSITORY[:TAG]]`

## Create and run a new container from an image

syntax: `docker run [OPTIONS] IMAGE [COMMAND] [ARG...]`

- -d Run container in background and print container ID

example: `docker run -p 3000:3000 -e PORT=3000 nextjs-cloudrun-app-alpine`

1. docker run：這是 Docker 命令的一部分，用來運行容器。
2. -p 3000:3000：這部分指定了容器的端口映射。-p 表示將主機（Host）的某個端口映射到容器的某個端口。在這個例子中，3000:3000 表示將主機的 3000 號端口映射到容器的 3000 號端口。這樣做後，你可以通過主機的 3000 號端口來訪問容器中運行的應用程式。
3. -e PORT=3000：這部分指定了容器運行時的環境變數。-e 表示設定一個環境變數，這裡將環境變數 PORT 設定為 3000。這個環境變數可能會在容器內的應用程式中被使用，用來指定應用程式監聽的端口。  
   這裡的 PORT 對應到 package.json 的 scripts 裡的 '$PORT' 變數
4. nextjs-cloudrun-app-alpine：這是容器的映像名稱。通過這個名稱，Docker 會找到並運行指定的映像。這部分是在運行容器時指定要使用的映像。

## List containers

syntax: `docker container ls [OPTIONS]`

- -a Show all containers (default shows just running)

## Remove one or more containers

syntax: `docker rm [OPTIONS] CONTAINER [CONTAINER...]`

## Execute a command in a running container

syntax: `docker exec [OPTIONS] CONTAINER COMMAND [ARG...]`  
example: `docker exec -it 54311ae83b93 sh`

1. docker exec：這是 Docker 命令的一部分，用來在一個運行中的容器內執行指定的命令。
2. -it：這部分選項用來指定命令的執行方式。-i 表示互動式，保持標準輸入流（stdin）開啟，允許用戶輸入命令。-t 表示創建一個虛擬終端（tty），使命令的輸出在終端上更好地顯示。
3. 54311ae83b93：這是容器的 ID 或名稱。你需要提供正在運行的容器的唯一識別符，以便 Docker 知道要在哪個容器內執行命令。在這個例子中，54311ae83b93 是一個假想的容器 ID。
4. sh：這是要在容器內執行的命令。在這個例子中，它是一個 Unix-like 系統中的 shell 命令，通常用於互動式的命令行界面。

# Deploy to google cloud run

## setup GCP Service Account
1. 到 https://console.cloud.google.com/
2. 創建 project nextjs-cloudrun-app
3. 點擊左上角漢堡 -> 點擊 Billing -> 點擊左側欄 Billing Account -> 選擇 Manage billing accounts -> 點擊 My projects tab -> 找到 nextjs-cloudrun-app project -> 點擊專案的 Actions ... -> 點擊 Change billing ，把 Bill account 黏到這個專案上  
   一個帳戶只能有五個專案可以 enable billing ，只有 enable billing 的專案才能用 cloud run service
4. 設定 Service Account
   1. 點擊左上角漢堡 -> 點擊 IAM & Admin -> 點擊 Service Accounts -> 點擊 Create service account -> 輸入  Service account name -> 點擊 Create and continue
   2. 點擊 Select a role ，選擇 Basic ，選擇 Editor ，讓這個 service account 有 enable 或 disable api 的權限 -> 點擊 Add another role ，點擊 Select a role ，輸入 cloud run admin ，選擇 Cloud Run Admin ，讓這個 service account 有控制 Cloud Run 的權限，可以 start or stop instaces 等等 -> 點擊 Add another role ，點擊 Select a role ，輸入 storage admin ，選擇 Storage Admin ，讓這個 service account 可以 push 東西到 Container Registry 的權限 -> 點擊 Add another role ，點擊 Select a role ，輸入 service account user ，選擇 Service Account User ，讓這個 service account 可以以 service account 的身份 run operations -> 點擊 Continue 
   3. 點擊 DONE
5. 找到剛才創建的 service account -> 點擊 Actions ... -> 點擊 Manage keys -> 點擊 Add key -> 點擊 Create new key -> Key type 選擇 JSON -> 點擊 CREATE -> 會下載一個 JSON 金鑰檔

## setup github actions
1. 創建 .github/workflows/cloud-run.yml 檔案，定義 github actions 詳細代碼請參考此檔案
2. 到 GitHub -> Settings ->  Secrets and variables -> Actions -> Secrets -> click New repository secret button -> 在 Name 輸入 CLOUD_RUN_PROJECT_NAME 對應到 cloud-run.yml 裡的 ${{ secrets.CLOUD_RUN_PROJECT_NAME }} -> 到 GCP 選擇專案的地方可以看到專案的 ID 複製起來貼到 Secret -> click Add secret button
3. 把 setup GCP Service Account 步驟五拿到的金鑰檔用 base64 encode ，命令是 `base64 -i 金鑰檔位址` ，複製拿到的字串， click New repository secret button -> 在 Name 輸入 CLOUD_RUN_SERVICE_ACCOUNT 對應到 cloud-run.yml 裡的 ${{ secrets.CLOUD_RUN_SERVICE_ACCOUNT }} -> 將剛剛複製的字串貼到 Secret -> click Add secret button  
   為什麼 json 要 bas64 encode 可以參考這篇文 https://github.com/actions/runner/issues/1942
   
