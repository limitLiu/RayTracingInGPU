# NeoVim 开发配置

确定你的 NeoVim 已经配置好 sourcekit, 接着需要在设备上安装 **xcode-build-server**

```
brew install xcode-build-server
```

继续安装 **xcpretty**

```
gem install xcpretty
gem install xcodeproj
```

然后用 Xcode 执行一下该应用, 之后在项目根目录执行

```
xcodebuild -resolvePackageDependencies -project RayTracingInGPU.xcodeproj
xcodebuild \
    -project ./RayTracingInGPU.xcodeproj \
    -scheme RayTracingInGPU \
    -destination "platform=macOS,arch=arm64,name=My Mac" \
    | xcpretty \
    -r json-compilation-database \
    --output ./compile_commands.json
xcode-build-server config -scheme RayTracingInGPU -project ./*.xcodeproj
```

然后用 NeoVim 打开项目，在命令模式下执行

```
:XcodebuildSetup
```

### 注意事项

如果更新系统后，最好是把项目根目录的 .nvim 文件夹删掉再重新执行 setup  
如果想构建并启动当前项目，可以

```
:XcodebuildBuildRun
```
