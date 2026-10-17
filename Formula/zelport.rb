class Zelport < Formula
  desc "Local HTTP reverse proxy for named localhost services"
  homepage "https://github.com/zelport/zelport"
  license "MIT"
  version "0.10.0"

  on_macos do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_darwin_arm64.tar.gz"
      sha256 "58fef0eb94c32734ee9105b187d2abeb3c955c10946b60913f0c9d426a937a57"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_darwin_amd64.tar.gz"
      sha256 "f18f2815f3a67dfcad2fac9bcea6e295b48c9996c40b6cbadd0f7d95d669a614"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_linux_arm64.tar.gz"
      sha256 "a170434606969b48ff5adec8f3a40293f81214c2b776fc0ffc8152483ab9f72c"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.0/zelport_0.10.0_linux_amd64.tar.gz"
      sha256 "7d6217cd104e9f3d0109a5baddf8ed0d0797caa4d8df0e23be46eba1ce585738"
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
