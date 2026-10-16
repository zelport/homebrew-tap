class Zelport < Formula
  desc "Local HTTP gateway for named localhost services"
  homepage "https://github.com/zelport/zelport"
  version "0.1.0-preview.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.1.0-preview.5/zelport_0.1.0-preview.5_darwin_arm64.tar.gz"
      sha256 "1a94b2bd00e51117e84e4ff7a6cb4cd91a6a4c4cf9779e9527389167bf67d8e1"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.1.0-preview.5/zelport_0.1.0-preview.5_darwin_amd64.tar.gz"
      sha256 "28d0905c3a05f36f63488d4b42fb85cf9e702e095f20fa44512bf594e0ee5060"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.1.0-preview.5/zelport_0.1.0-preview.5_linux_arm64.tar.gz"
      sha256 "16a6a5cf78a04c53cf4e4b85e63de98a322b7e1d7569928ef88df9d93c0fcc91"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.1.0-preview.5/zelport_0.1.0-preview.5_linux_amd64.tar.gz"
      sha256 "e66b39feb828ef77a8503b26221a0d5953548934cc2d0446c24d28ab26bd15ce"
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
    assert_match "HTTP gateway", shell_output("#{bin}/zelport --help 2>&1")
  end
end
