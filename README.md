# agent-sandbox

AI コーディングエージェント（Claude Code など）を隔離された環境で動かすためのコンテナイメージと補助スクリプトです。
ホストのディレクトリをコンテナにマウントし、その中でエージェントに作業させます。

## イメージの内容

`Dockerfile` は Fedora 45 をベースに、次のものを入れます。

- `curl`, `git`, `vim`, `bubblewrap`
- 非 root ユーザー `agent`（UID/GID 1000、ホームは `/home/agent`）
- [Claude Code](https://claude.ai/install.sh)
- [herdr](https://herdr.dev/install.sh)

## 必要なもの

- `container` CLI（スクリプトは `container build` / `container create` を呼び出します）
- `git`（イメージタグをブランチ名から決めるため）

## 使い方

### 1. イメージをビルドする

```sh
./build.sh
```

イメージ名は `ghcr.io/ahrimak/<リポジトリのディレクトリ名>:<ブランチ名>` になります。

- ブランチ名に含まれる `[A-Za-z0-9_.-]` 以外の文字（`/` など）は `-` に置き換えます。例: `feature/foo` → `feature-foo`
- detached HEAD の場合は 7 桁の短いコミット ID をタグに使います。

### 2. コンテナを作成する

```sh
./create.sh <directory> [container-name]
```

- `<directory>`: コンテナにマウントするホスト側のディレクトリ。`/home/agent/<ディレクトリ名>` にマウントし、そこを作業ディレクトリにします。
- `[container-name]`: 省略すると `<イメージ名>-<タグ>` を使います（例: `agent-sandbox-main`）。

コンテナは現在のブランチに対応するタグのイメージから作成するので、先に同じブランチで `build.sh` を実行しておいてください。

例:

```sh
./create.sh ~/src/my-project
# created: agent-sandbox-main (/Users/you/src/my-project -> /home/agent/my-project)
```

### 3. コンテナを起動して入る

```sh
container start agent-sandbox-main
container exec -it agent-sandbox-main bash
```

コンテナ内では `claude` などのコマンドが使えます。

## ファイル構成

| ファイル     | 説明                                              |
| ------------ | ------------------------------------------------- |
| `Dockerfile` | サンドボックス用イメージの定義                    |
| `build.sh`   | ブランチ名をタグにしてイメージをビルドする        |
| `create.sh`  | ホストのディレクトリをマウントしたコンテナを作成する |
