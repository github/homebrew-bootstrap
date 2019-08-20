class Kind < Formula
  desc "Kubernetes IN Docker - local clusters for testing Kubernetes"
  homepage "https://kind.sigs.k8s.io/"
  url "https://github.com/kubernetes-sigs/kind/archive/v0.3.0.tar.gz"
  sha256 "3d62392919bd93421acf61a17502f9dab8ec8d2a792b342b7a1abd749dbf81ef"

  depends_on "docker" => :build

  def install
    bin.mkpath
    system "make", "INSTALL_DIR=#{bin}", "install"
  end

  test do
    assert_equal "kind version v#{version}", shell_output("#{bin}/kind --version").chomp
  end
end
