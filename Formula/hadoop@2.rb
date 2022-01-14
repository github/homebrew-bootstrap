class HadoopAT2 < Formula
  desc "Framework for distributed processing of large data sets"
  homepage "https://hadoop.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz"
  mirror "https://archive.apache.org/dist/hadoop/common/hadoop-2.8.2/hadoop-2.8.2.tar.gz"
  sha256 "aea99c7ce8441749d81202bdea431f1024f17ee6e0efb3144226883207cc6292"

  depends_on "openjdk@8"

  def install
    rm_f Dir["bin/*.cmd", "sbin/*.cmd", "libexec/*.cmd", "etc/hadoop/*.cmd"]
    libexec.install %w[bin sbin libexec share etc]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
    sbin.write_exec_script Dir["#{libexec}/sbin/*"]
    # But don't make rcc visible, it conflicts with Qt
    (bin/"rcc").unlink

    inreplace "#{libexec}/etc/hadoop/hadoop-env.sh",
      "export JAVA_HOME=${JAVA_HOME}",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
    inreplace "#{libexec}/etc/hadoop/yarn-env.sh",
      "# export JAVA_HOME=/home/y/libexec/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
    inreplace "#{libexec}/etc/hadoop/mapred-env.sh",
      "# export JAVA_HOME=/home/y/libexec/jdk1.6.0/",
      "export JAVA_HOME=\"$(/usr/libexec/java_home)\""
  end

  def caveats
    <<~EOS
      In Hadoop's config file:
        #{libexec}/etc/hadoop/hadoop-env.sh,
        #{libexec}/etc/hadoop/mapred-env.sh and
        #{libexec}/etc/hadoop/yarn-env.sh
      $JAVA_HOME has been set to be the output of:
        /usr/libexec/java_home
    EOS
  end

  test do
    system bin/"hadoop", "fs", "-ls"
  end
end
