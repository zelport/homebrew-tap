class Zelport < Formula
  desc "Local HTTP reverse proxy for named localhost services"
  homepage "https://github.com/zelport/zelport"
  license "MIT"
  version "0.10.1"

  on_macos do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.1/zelport_0.10.1_darwin_arm64.tar.gz"
      sha256 "4f1c88d266bf3bc123819422a867f962d43c8d312b7e4ea9cb79a1477e5e0143"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.1/zelport_0.10.1_darwin_amd64.tar.gz"
      sha256 "ae5ef027be938404225401e76ce4491d1e609da493eda315e99ea19a92c6ba15"
    end
  end
  on_linux do
    on_arm do
      url "https://github.com/zelport/zelport/releases/download/v0.10.1/zelport_0.10.1_linux_arm64.tar.gz"
      sha256 "2d10659c8413fd0320134c1114cf8823aad9550c9f4b9f642d7f82cb59b87456"
    end
    on_intel do
      url "https://github.com/zelport/zelport/releases/download/v0.10.1/zelport_0.10.1_linux_amd64.tar.gz"
      sha256 "06842996933f571bcbc716e116261fa20c4bad972a60970dce78eafc08e969d7"
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
