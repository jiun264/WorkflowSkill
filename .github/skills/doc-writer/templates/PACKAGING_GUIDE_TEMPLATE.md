# 本地打包指引模板 (Local Packaging Guide)

本文件提供不同主流程式語言與專案類型在完全離線或本地環境下的打包實踐標準。

---

## 1. PowerShell / Skill 套件本地打包

### 打包指令
```powershell
# 打包特定 skill
powershell -ExecutionPolicy Bypass -File .\scripts\package-skill.ps1 -SkillName "<skill-name>" -OutputDir ".\dist"

# 打包所有 skills
powershell -ExecutionPolicy Bypass -File .\scripts\package-skills.ps1 -OutputDir ".\dist"
```

### 產物結構
```text
dist/
├── <skill-name>-v<version>.zip
├── manifest.json
└── checksum.sha256
```

---

## 2. Node.js / TypeScript 專案本地打包

### 打包指令 (完全離線)
```bash
# 1. 本地編譯
npm run build

# 2. 封裝成 tarball (.tgz)
npm pack --pack-destination ./dist
```

### 本地安裝驗證
```bash
# 在其他專案安裝該本機 tarball
npm install ./dist/my-package-1.0.0.tgz
```

---

## 3. Python 專案本地打包

### 打包指令
```bash
# 1. 確保安裝 build 套件
python -m pip install --upgrade build

# 2. 本地產生 wheel 與 sdist (.whl / .tar.gz)
python -m build --outdir ./dist
```

### 本地安裝驗證
```bash
pip install ./dist/my_package-1.0.0-py3-none-any.whl
```

---

## 4. .NET / C# 專案本地打包

### 打包指令
```bash
# 本地建置並封裝 NuGet 套件
dotnet pack -c Release -o ./dist
```

### 本地安裝驗證
```bash
# 本地 NuGet 來源引用
dotnet add package MyPackage --source ./dist
```

---

## 5. Go 專案本地打包

### 打包指令
```bash
# 產出靜態二進制執行檔
go build -ldflags="-s -w" -o ./dist/app.exe ./cmd/main.go
```
