class Zelport < Formula
  desc "Local HTTP reverse proxy for named localhost services"
  homepage "https://github.com/zelport/zelport"
  license "MIT"
  version "0.10.0"

  on_macos do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_darwin_arm64.tar.gz"
      sha256 "424aba73bbdbc82145eec539b4d891335f6a7d1fbf679a8b0dd456ba575b3612"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_darwin_amd64.tar.gz"
      sha256 "1943731c592b43826df2616f65f3d15e7e0d8278c85e2ce32e04861475ffccee"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_linux_arm64.tar.gz"
      sha256 "4905ca85d604dd102a071a138cb24f8b40ebdbe78b89dd6810a5e4bc77a70ed1"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_linux_amd64.tar.gz"
      sha256 "e6ec8ad37429d967afe94f2eb6ab1ff227a9ed2c7ddacc6c13c322fd1039121e"
    end
  end

  def install
    bin.install "zelport"
    pkgshare.install "THIRD_PARTY_NOTICES.txt"
  end

  service do
    run [opt_bin/"zelport"]
    keep_alive true
    require_root false
    environment_variables PATH: "#{std_service_path_env}:/usr/local/bin"
    log_path var/"log/zelport.log"
    error_log_path var/"log/zelport.log"
    restart_delay 5
    throttle_interval 10
    stop_timeout 15
  end

  def caveats
    <<~EOS
      Run Zelport and brew services as your regular user, without sudo.
      Installation does not start Zelport. Use either zelport in a terminal or
      brew services start zelport for automatic startup at login.
      The dashboard is at http://localhost:8080.
      Services do not inherit your interactive shell environment. See the
      Homebrew documentation in the Zelport repository for custom configuration
      paths, backend CLI tools and SSH agent access.
    EOS
  end

  test do
    assert_match "zelport #{version}", shell_output("#{bin}/zelport --version")
    assert_match "HTTP reverse proxy", shell_output("#{bin}/zelport --help 2>&1")
  end
end
