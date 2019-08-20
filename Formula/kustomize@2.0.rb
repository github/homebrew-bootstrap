class KustomizeAT20 < Formula
  desc "Template-free customization of Kubernetes YAML manifests"
  homepage "https://github.com/kubernetes-sigs/kustomize"
  url "https://github.com/kubernetes-sigs/kustomize.git",
      :tag      => "v2.0.3",
      :revision => "a6f65144121d1955266b0cd836ce954c04122dc8"

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["CGO_ENABLED"] = "0"

    revision = Utils.popen_read("git", "rev-parse", "HEAD").strip
    tag = Utils.popen_read("git", "describe", "--tags").strip
    dir = buildpath/"src/sigs.k8s.io/kustomize"
    dir.install buildpath.children - [buildpath/".brew_home"]
    cd dir do
      ldflags = %W[
        -s -X sigs.k8s.io/kustomize/pkg/commands/misc.kustomizeVersion=#{tag}
        -X sigs.k8s.io/kustomize/pkg/commands/misc.gitCommit=#{revision}
        -X sigs.k8s.io/kustomize/pkg/commands/misc.buildDate=#{Time.now.iso8601}
      ]
      system "go", "install", "-ldflags", ldflags.join(" ")
      bin.install buildpath/"bin/kustomize" => "kustomize@2.0"
      prefix.install_metafiles
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kustomize@2.0 version")

    (testpath/"kustomization.yaml").write <<~EOS
      resources:
      - service.yaml
      patches:
      - patch.yaml
    EOS
    (testpath/"patch.yaml").write <<~EOS
      apiVersion: v1
      kind: Service
      metadata:
        name: brew-test
      spec:
        selector:
          app: foo
    EOS
    (testpath/"service.yaml").write <<~EOS
      apiVersion: v1
      kind: Service
      metadata:
        name: brew-test
      spec:
        type: LoadBalancer
    EOS
    output = shell_output("#{bin}/kustomize@2.0 build #{testpath}")
    assert_match /type:\s+"?LoadBalancer"?/, output
  end
end
