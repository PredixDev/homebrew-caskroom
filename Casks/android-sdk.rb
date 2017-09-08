cask 'android-sdk' do
  version '3859397'
  sha256 '4a81754a760fce88cba74d69c364b05b31c53d57b26f9f82355c61d5fe4b9df9'

  # dl.google.com/android/repository was verified as official when first introduced to the cask
  url "https://dl.google.com/android/repository/sdk-tools-darwin-#{version}.zip"
  name 'android-sdk'
  homepage 'https://developer.android.com/index.html'

  conflicts_with cask: 'android-platform-tools'

  build_tools_version = '26.0.0'

  binary "#{staged_path}/build-tools/#{build_tools_version}/aapt"
  binary "#{staged_path}/build-tools/#{build_tools_version}/aapt2"
  binary "#{staged_path}/build-tools/#{build_tools_version}/aarch64-linux-android-ld"
  binary "#{staged_path}/build-tools/#{build_tools_version}/aidl"
  binary "#{staged_path}/build-tools/#{build_tools_version}/arm-linux-androideabi-ld"
  binary "#{staged_path}/build-tools/#{build_tools_version}/bcc_compat"
  binary "#{staged_path}/build-tools/#{build_tools_version}/dexdump"
  binary "#{staged_path}/build-tools/#{build_tools_version}/dx"
  binary "#{staged_path}/build-tools/#{build_tools_version}/i686-linux-android-ld"
  binary "#{staged_path}/build-tools/#{build_tools_version}/llvm-rs-cc"
  binary "#{staged_path}/build-tools/#{build_tools_version}/mainDexClasses"
  binary "#{staged_path}/build-tools/#{build_tools_version}/mipsel-linux-android-ld"
  binary "#{staged_path}/build-tools/#{build_tools_version}/split-select"
  binary "#{staged_path}/build-tools/#{build_tools_version}/x86_64-linux-android-ld"
  binary "#{staged_path}/build-tools/#{build_tools_version}/zipalign"
  binary "#{staged_path}/emulator/bin64/e2fsck"
  binary "#{staged_path}/emulator/bin64/fsck.ext4"
  binary "#{staged_path}/emulator/bin64/mkfs.ext4"
  binary "#{staged_path}/emulator/bin64/resize2fs"
  binary "#{staged_path}/emulator/bin64/tune2fs"
  binary "#{staged_path}/emulator/emulator"
  binary "#{staged_path}/emulator/emulator-check"
  binary "#{staged_path}/emulator/emulator64-arm"
  binary "#{staged_path}/emulator/emulator64-crash-service"
  binary "#{staged_path}/emulator/emulator64-mips"
  binary "#{staged_path}/emulator/emulator64-x86"
  binary "#{staged_path}/emulator/mksdcard"
  binary "#{staged_path}/platform-tools/adb"
  binary "#{staged_path}/platform-tools/dmtracedump"
  binary "#{staged_path}/platform-tools/etc1tool"
  binary "#{staged_path}/platform-tools/fastboot"
  binary "#{staged_path}/platform-tools/hprof-conv"
  binary "#{staged_path}/platform-tools/systrace/systrace.py"
  binary "#{staged_path}/tools/android"
  binary "#{staged_path}/tools/bin/archquery"
  binary "#{staged_path}/tools/bin/avdmanager"
  binary "#{staged_path}/tools/bin/jobb"
  binary "#{staged_path}/tools/bin/lint"
  binary "#{staged_path}/tools/bin/monkeyrunner"
  binary "#{staged_path}/tools/bin/screenshot2"
  binary "#{staged_path}/tools/bin/sdkmanager"
  binary "#{staged_path}/tools/bin/uiautomatorviewer"
  binary "#{staged_path}/tools/mksdcard"
  binary "#{staged_path}/tools/monitor"

  proxy_env = ENV['HTTP_PROXY'] || ENV['http_proxy']
  proxy_parts = /http:\/\/(.*):(\d*)/i.match(proxy_env)

  unless proxy_parts === nil || proxy_parts[1] == nil || proxy_parts[2] == nil
    proxy_host = proxy_parts[1]
    proxy_port = proxy_parts[2]
  end

  preflight do
    unless proxy_host == nil
      args = ['tools', 'platform-tools', "build-tools;#{build_tools_version}", '--no_https', '--proxy=http', "--proxy_host=#{proxy_host}", "--proxy_port=#{proxy_port}"]
    else
      args = ['tools', 'platform-tools', "build-tools;#{build_tools_version}"]
    end

    system_command "#{staged_path}/tools/bin/sdkmanager", args: args, input: 'y'
  end

  postflight do
    FileUtils.ln_sf(staged_path.to_s, "#{HOMEBREW_PREFIX}/share/android-sdk")
  end

  uninstall_postflight do
    FileUtils.rm("#{HOMEBREW_PREFIX}/share/android-sdk")
  end

  caveats <<-EOS.undent
    We will install android-sdk-tools, platform-tools, and build-tools for you.
    You can control android sdk packages via the sdkmanager command.

    We are using following proxy configuration:
      proxy_host: #{proxy_host || 'none'}
      proxy_port: #{proxy_port || 'none'}

    You may want to add to your profile:
      'export ANDROID_SDK_ROOT=#{HOMEBREW_PREFIX}/share/android-sdk'

    This operation may take up to 10 minutes depending on your internet connection.
    Please, be patient.
  EOS
end
