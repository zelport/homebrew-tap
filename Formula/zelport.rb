class Zelport < Formula
  desc "Local HTTP reverse proxy for named localhost services"
  homepage "https://github.com/zelport/zelport"
  license "MIT"
  version "0.11.0"

  on_macos do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.11.0/zelport_0.11.0_darwin_arm64.tar.gz"
      sha256 "3befd14abbc1be3ecdfe3e49801a7173cb88998ea48aff187db1625efd868b0d"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.11.0/zelport_0.11.0_darwin_amd64.tar.gz"
      sha256 "b7a8dba4d562f30460294cda71b79a2b997d0d95d375822d4c45000bdd61962c"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.11.0/zelport_0.11.0_linux_arm64.tar.gz"
      sha256 "b21e21ab13c145cb2cd0e80398abf7564cc9836272095aab76e4c29b70e71b82"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.11.0/zelport_0.11.0_linux_amd64.tar.gz"
      sha256 "7889b58d824288f90783b09a12b0f0e99d5d7f11ec6dc800bded8f323f7389f5"
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
