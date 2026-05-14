# typed: false
# frozen_string_literal: true

# Homebrew formula for TimeNest.
#
# Canonical source lives in the main repo at homebrew/timenest.rb. The
# tap (momenbasel/homebrew-timenest) hosts an identical copy. The
# release workflow rewrites url + sha256 + version on every tagged
# release and opens a PR against the tap.
#
# Install:
#   brew tap momenbasel/timenest
#   brew install timenest
class Timenest < Formula
  desc "Network Time Machine server (Samba + Avahi + admin UI) for Mac, RPi, and Linux"
  homepage "https://github.com/momenbasel/timenest"
  url "https://github.com/momenbasel/timenest/archive/refs/tags/v0.0.0.tar.gz"
  version "0.0.0"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"

  depends_on "bash"

  def install
    # Stage the compose stack, scripts, and config templates under libexec.
    libexec.install "docker-compose.yml"
    libexec.install ".env.example"
    libexec.install "install.sh"
    libexec.install "samba"
    libexec.install "avahi"
    libexec.install "scripts"
    libexec.install "web"
    (libexec/".version").write version.to_s

    # CLI wrapper goes on PATH; default TIMENEST_HOME points at libexec
    # so users don't have to clone the repo.
    bin.install "bin/timenest"
    inreplace bin/"timenest", 'TIMENEST_HOME="${TIMENEST_HOME:-$HOME/timenest}"',
              "TIMENEST_HOME=\"${TIMENEST_HOME:-#{libexec}}\""
  end

  def caveats
    <<~EOS
      TimeNest requires Docker. Install Docker Desktop or OrbStack first:
        brew install --cask docker     # or: brew install --cask orbstack

      First-run setup (creates ~/.timenest with .env + backup dir):
        timenest up

      Manage the stack:
        timenest status    # show container status
        timenest logs      # tail logs
        timenest update    # pull latest images
        timenest down      # stop everything
    EOS
  end

  service do
    run [opt_bin/"timenest", "up"]
    keep_alive false
    log_path var/"log/timenest.log"
    error_log_path var/"log/timenest.log"
  end

  test do
    assert_match "timenest", shell_output("#{bin}/timenest --help")
    assert_path_exists libexec/"docker-compose.yml"
  end
end
