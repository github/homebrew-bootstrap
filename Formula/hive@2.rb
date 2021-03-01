class HiveAT2 < Formula
  desc "Hadoop-based data summarization, query, and analysis"
  homepage "https://hive.apache.org"
  url "https://downloads.apache.org/hive/hive-2.3.8/apache-hive-2.3.8-bin.tar.gz"
  mirror "https://archive.apache.org/dist/hive/hive-2.3.8/apache-hive-2.3.8-bin.tar.gz"
  sha256 "3746528298fb70938e30bfbb66f756d1810acafbe86ba84edef7bd3455589176"

  bottle :unneeded

  depends_on "hadoop@2"
  depends_on "openjdk@8"

  def install
    rm_f Dir["bin/*.cmd", "bin/ext/*.cmd", "bin/ext/util/*.cmd"]
    libexec.install %w[bin conf examples hcatalog lib scripts]

    Pathname.glob("#{libexec}/bin/*") do |file|
      next if file.directory?

      (bin/file.basename).write_env_script file,
        Language::Java.java_home_env("1.7+").merge(HIVE_HOME: libexec)
    end
  end

  def caveats
    <<~EOS
      Hadoop must be in your path for hive executable to work.
      If you want to use HCatalog with Pig, set $HCAT_HOME in your profile:
        export HCAT_HOME=#{opt_libexec}/hcatalog
    EOS
  end

  test do
    system bin/"schematool", "-initSchema", "-dbType", "derby"
    assert_match "Hive #{version}", shell_output("#{bin}/hive --version")
  end
end
