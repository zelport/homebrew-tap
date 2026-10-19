class Zelport < Formula
  desc "Local HTTP reverse proxy for named localhost services"
  homepage "https://github.com/zelport/zelport"
  license "MIT"
  version "0.10.2"

  on_macos do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.2/zelport_0.10.2_darwin_arm64.tar.gz"
      sha256 "d678995bf55c4884e9f858c3e14697ee49209fcf3b399f1eeecb387a3314d4cc"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.2/zelport_0.10.2_darwin_amd64.tar.gz"
      sha256 "282c6563f1f086028f5aba379faafe47055fc7e3f2ad46128df95e2fc9209cea"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.2/zelport_0.10.2_linux_arm64.tar.gz"
      sha256 "c55219310f6d762438f29f34f76998e16fd47458c6148696152a24703bda3215"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.2/zelport_0.10.2_linux_amd64.tar.gz"
      sha256 "d4318e8b315bba019335e589d73e31346e4060ac00a7f4181a143049d10b10c9"
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
