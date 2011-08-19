$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'rubygems'
require 'bundler'
require 'rake'
Bundler.setup
require 'thor'
require 'nokogiri'
require 'net/https'
require 'net/ssh'
require 'net/scp'
require 'open-uri'

class DeployHelper < Bundler::GemHelper
  include Rake::DSL

  # override
  def self.install_tasks(opts = nil)
    dir = caller.find { |c| /Rakefile:/ }[/^(.*?)\/Rakefile:/, 1]
    self.new(dir, opts && opts[:name]).install
  end

  # override
  def initialize(base, name = nil)
    Bundler.ui = Bundler::UI::Shell.new(Thor::Shell::Color.new)
    @base = base
  end

  # override
  def install
    [:production, :qa].each do |env|
      desc "=[ #{env.to_s.gsub('_', ' ').upcase} ]="
      task env do
        Bundler.ui.warn "Use: rake <env>:task"
      end
      namespace env do
        task :environment => :build do
          @environment = env.to_s
        end

        desc "Setup #{name} (#{version}) to #{env.to_s}"
        task :setup => :environment do
          setup
        end

        desc "Deploy #{name} (#{version}) to #{env.to_s}"
        task :deploy => :environment do
          if not user_verifies_operation_for_production_environment "deploy"
            Bundler.ui.confirm "Aborted."
            return
          end
          deploy
        end

        desc "Upload #{name} (#{version}) to #{env.to_s}"
        task :upload => :environment do
          upload
        end

        desc "Restart #{name} (#{version}) to #{env.to_s}"
        task :restart => :environment do
          if not user_verifies_operation_for_production_environment "restart"
            Bundler.ui.confirm "Aborted."
            return
          end
          restart
        end

        desc "Start #{name} (#{version}) to #{env.to_s}"
        task :start => :environment do
          start
        end

        desc "Stop #{name} (#{version}) to #{env.to_s}"
        task :stop => :environment do
          if not user_verifies_operation_for_production_environment "stop"
            Bundler.ui.confirm "Aborted."
            return
          end
          stop
        end

        desc "Check #{name} (#{version}) to #{env.to_s}"
        task :verify => :environment do
          verify
        end

        desc "Rollback #{name} (#{version}) to #{env.to_s}"
        task :rollback => :environment do
          if not user_verifies_operation_for_production_environment "rollback"
            Bundler.ui.confirm "Aborted."
            return
          end
          rollback
        end

        namespace :db do
          desc "Deploy latest liquibase bundle"
          task :deploy => :backup do
            upload_db
          end

          desc "Migrate Database to newest"
          task :migrate => :deploy do
            if not user_verifies_operation_for_production_environment "migrate"
              Bundler.ui.confirm "Aborted."
              return
            end
            migrate
          end

          desc "Backup Database"
          task :backup => :environment do
            backup_db
          end

          # Don't support dropping data in production
          unless env.to_s == 'production'

          end
        end

      end
    end

    namespace :local do
      desc "Migrate db for localhost"
      task :migrate do
        @environment = 'local'
        local_liquibase_invoke('migrate')
      end

      desc "Drop db for localhost"
      task :drop_all do
        @environment = 'local'
        local_liquibase_invoke('dropAll')
      end

      desc "Drop and create empty db for localhost"
      task :init do
        @environment = 'local'
        local_mysql_init
      end
    end

    desc "Build project if #{jetty_jar_path} does not exist"
    task :build do
      build_project_if_needed
    end

    desc "Start jetty for given default env (dev)"
    task :server do
      local_jetty_init
    end

    desc "Start jetty for given default env (dev)"
    task :mybring do
      local_jetty_init('mybring_dev')
    end

    desc "Start jetty for mybring without dummy user (dev)"
    task :mybring_integration do
      local_jetty_init('mybring_integration_dev')
    end

  end

  # override
  def version
    @version ||= parse_project_version
  end

  def parse_project_version
    doc = Nokogiri::XML(open('pom.xml'))
    doc.xpath("//xmlns:project/xmlns:version/text()").first.content
  end

  # override
  def name
    "developer-site"
  end

  def environment
    @environment
  end

  def build_project_if_needed
      unless File.exists?(jetty_jar_path) or File.exists?(liquibase_jar_path)
      Bundler.ui.error "Error: #{jetty_jar_path} does not exist!"
      Bundler.ui.info ""
      Bundler.ui.warn "You must build the project first with maven"
      Bundler.ui.info ""
      Bundler.ui.warn "try: 'mvn clean install -Prelease'\n"
      Kernel.exit
    end
  end

  def jetty_jar_path
    "developer-site-jetty/target/#{name}-#{version}.jar"
  end

  def liquibase_jar_path
    File.dirname(__FILE__) + "/database/target/database-#{version}-jar-with-dependencies.jar"
  end

  def config
    @config ||= YAML::load_file(File.dirname(__FILE__) + '/config/config.yml')
  end

  def cfg(key)
    config[@environment][key.to_s]
  end

  # Convenience methods for reading configured values
  [:user, :prefix, :hosts, :database].each do |m|
    define_method m do
      cfg(m)
    end
  end

  ###
  ### localhost database/liquibase convenience
  ###

  def local_mysql_init
    Bundler.ui.info "Initializing local database..."
    sql = <<-EOS
    DROP DATABASE IF EXISTS #{database['db']};
    CREATE DATABASE #{database['db']};
    GRANT ALL ON #{database['db']}.* TO '#{database['username']}'@'#{database['host']}' IDENTIFIED BY '#{database['password']}';
    EOS
    IO.popen("mysql -uroot -p", 'w+') { |f| f.write sql; f.close }
    Bundler.ui.confirm "Done!"
  end

  def parse_liquibase_version
    doc = Nokogiri::XML(open(File.dirname(__FILE__) + '/pom.xml'))
    doc.xpath("//xmlns:project/xmlns:dependencyManagement/xmlns:dependencies/xmlns:dependency[xmlns:artifactId/text()='liquibase-core']/xmlns:version/text()").first.content
  end

  def parse_mysql_version
    doc = Nokogiri::XML(open(File.dirname(__FILE__) + '/pom.xml'))
    doc.xpath("//xmlns:project/xmlns:dependencyManagement/xmlns:dependencies/xmlns:dependency[xmlns:artifactId/text()='mysql-connector-java']/xmlns:version/text()").first.content
  end

  def local_liquibase_invoke(cmd)
    Bundler.ui.info "Executing liquibase(#{cmd}) on localhost database"

    migrations = File.dirname(__FILE__) + "/database/src/main/resources/"
    liquibase_jar = ENV['HOME'] + "/.m2/repository/org/liquibase/liquibase-core/#{parse_liquibase_version}/liquibase-core-#{parse_liquibase_version}.jar"
    mysql_connector_jar = ENV['HOME'] + "/.m2/repository/mysql/mysql-connector-java/#{parse_mysql_version}/mysql-connector-java-#{parse_mysql_version}.jar"

    [migrations, liquibase_jar, mysql_connector_jar].each do |f|
      unless File.exist?(f)
        Bundler.ui.error "Error: #{f} does not exist (in local maven repository?)! "
        Kernel.exit
      end
    end

    default_liquibase_args = [
            "--driver=com.mysql.jdbc.Driver",
            "--url=jdbc:mysql://#{database['host']}/#{database['db']}",
            "--username=#{database['username']}",
            "--password=#{database['password']}",
            "--changeLogFile=#{database['changelog']}"
    ]

    if ('Windows_NT'.== ENV['OS'])
      cp_separator = ';'
    else
      cp_separator = ':'
    end

    exec("java -classpath #{migrations}#{cp_separator}#{mysql_connector_jar}#{cp_separator}#{liquibase_jar} liquibase.integration.commandline.Main #{default_liquibase_args.join(" ")} #{cmd}")
    Bundler.ui.confirm "Done!"
  end

  def local_jetty_init(app_env = 'dev')
    ENV['BOOKING_ROOT_DIR'] = "#{File.dirname(__FILE__)}"
    system("mvn -o compile test-compile -f #{File.dirname(__FILE__)}/pom.xml")
    maven_opts = "-Xdebug -Xrunjdwp:transport=dt_socket,address=8000,server=y,suspend=n -XX:MaxPermSize=512m -Xms256m -Xmx768m"
    jrebel_jar = "#{ENV['JREBEL_HOME']}/jrebel.jar"
    if File.exist?(jrebel_jar) and ENV['JREBEL']
      maven_opts = "#{maven_opts} -noverify -javaagent:#{jrebel_jar} -Drebel.velocity_plugin=true -Drebel.log4j-plugin=true -Drebel.jackson_plugin=true -XX:+UseParallelGC -XX:+CMSClassUnloadingEnabled"
    end
    ENV['MAVEN_OPTS'] = maven_opts
    exec("mvn -o jetty:run -f #{File.dirname(__FILE__)}/webapp/pom.xml -Djetty.port=8090 -Djetty.stopPort=10001 -DCONSTRETTO_TAGS=#{app_env} -Djetty.scanIntervalSeconds=5 -Dnet.jawr.debug.on=true")
    Bundler.ui.confirm "Aye."
  end

  ###
  ### Configure
  ###

  def setup
    hosts.each do |host|
      Bundler.ui.info "Setting up Miniapp: #{host}"
      Net::SSH.start(host, user) do |ssh|
        ssh.exec!("mkdir -p #{prefix}/{apps,logs,deployments}/#{name}")
        ssh.exec!("mkdir -p #{prefix}/{conf,bin,sql,www}")
      end

      Net::SCP.start(host, user) do |scp|
        Dir["config/bin/**"].each { |f| scp.upload!(f, "#{prefix}/bin/") }
        Dir["config/#{environment}/bin/**"].each { |f| scp.upload!(f, "#{prefix}/bin/") }
        Dir["config/#{environment}/conf/**"].each { |f| scp.upload!(f, "#{prefix}/conf/") }
        Dir["config/#{environment}/www/**"].each { |f| scp.upload!(f, "#{prefix}/www/", :recursive => true) }
      end

      if (cfg(:solaris))
        Net::SSH.start(host, user) do |ssh|
          ssh.exec!("svcadm disable #{name}")
          ssh.exec!("svccfg delete #{name}")
          ssh.exec!("svccfg validate #{prefix}/conf/#{name}-smf.xml")
          ssh.exec!("svccfg import #{prefix}/conf/#{name}-smf.xml")
          ssh.exec!("svcadm clear #{name}")
        end
      end

    end
    Bundler.ui.confirm "Setup done!"
  end

  def deploy
    hosts.each do |host|
      upload_host(host)
      stop_host(host)
      start_host(host)
    end

    Bundler.ui.info "Waiting 20 seconds for webapps to come back up..."
    sleep 20
    verify
  end

  def upload
    hosts.each do |host|
      upload_host(host)
    end
  end

  def upload_host(host)
    Net::SSH.start(host, user) do |ssh|
      Bundler.ui.info "Marking previous release on #{host}..."
      ssh.exec!("touch #{prefix}/apps/#{name}/#{name}.jar") # In case it doesn't already exist
      ssh.exec!("mv #{prefix}/apps/#{name}/#{name}.jar #{prefix}/apps/#{name}/#{name}.jar.previous")
    end

    Bundler.ui.info "Uploading #{jetty_jar_path} to #{host}..."
    Net::SCP.start(host, user) do |scp|
      scp.upload!(jetty_jar_path, "#{prefix}/apps/#{name}")
    end

    Net::SSH.start(host, user) do |ssh|
      Bundler.ui.info "Symlinking new release..."
      ssh.exec("ln -sf #{prefix}/apps/#{name}/#{name}-#{version}.jar #{prefix}/apps/#{name}/#{name}.jar")
    end
  end

  def restart
    hosts.each do |host|
      stop_host(host)
      start_host(host)
    end
  end

  def stop
    hosts.each do |host|
      stop_host(host)
    end
  end

  def stop_host(host)
    Net::SSH.start(host, user) do |ssh|
      Bundler.ui.info "Stopping service on #{host}..."
      ssh.exec!(cfg(:stop_command))
    end
  end

  def start
    hosts.each do |host|
      start_host(host)
    end
  end

  def start_host(host)
    Net::SSH.start(host, user) do |ssh|
      Bundler.ui.info "Starting service on #{host}..."
      ssh.exec(cfg(:start_command))
    end
  end

  def upload_db
    server_file = "#{prefix}/sql/#{File.basename(liquibase_jar_path)}"

    Net::SCP.start(database['host'], user) do |scp|
      Bundler.ui.info "Uploading #{liquibase_jar_path}..."
      scp.upload!(liquibase_jar_path, server_file)
    end
  end

  def backup_db
    Net::SSH.start(database['host'], user) do |ssh|
      target_file = "#{prefix}/sql/#{database['db']}.#{Time.now.strftime('%Y%m%d%H%M')}.sql"
      Bundler.ui.warn "Backing up database... on #{database['host']} to #{target_file}"
      ssh.exec!("mysqldump -u#{database['username']} -p#{database['password']} #{database['db']} > #{target_file}")
    end
  end

  def exec_liquibase(cmd)
    server_file = "#{prefix}/sql/#{File.basename(liquibase_jar_path)}"
    Net::SSH.start(database['host'], user) do |ssh|
      Bundler.ui.warn "Running Liquibase command: #{cmd} on #{database['host']}"
      ssh.exec!("java -jar #{server_file} --url='jdbc:mysql://localhost/#{database['db']}' --username=#{database['username']} --password=#{database['password']} #{cmd}")
    end
  end

  def drop_all
    exec_liquibase('dropAll')
  end

  def migrate
    exec_liquibase('migrate')
  end

  def rebuild_db
    exec_liquibase('dropAll')
    exec_liquibase('migrate')
  end

  def verify
    running_version = get_http(cfg(:version_url))
    healthcheck_response = get_http(cfg(:healthcheck_url))

    dont_include = cfg(:healthcheck_dont_include) || 'FAIL'

    if (running_version != version)
      Bundler.ui.error "Version FAILED. Expected new running version was '#{version}', actual is '#{running_version}'"
    else
      Bundler.ui.confirm "Version OK! ('#{running_version}')"
    end

    if (healthcheck_response.include? dont_include)
      Bundler.ui.error "Health FAILED. Response should not include '#{dont_include}', response was:\n#{healthcheck_response}"
    else
      Bundler.ui.confirm "Health OK! (Doesn't contain '#{dont_include}')"
    end

  end

  def get_http(urlstring)
    begin
      uri = URI.parse(urlstring)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 5
      http.open_timeout = 5

      if (uri.scheme == 'https')
        http.use_ssl = true
        http.ssl_timeout = 5
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = Net::HTTP::Get.new(uri.request_uri)
      if (uri.user)
        req.basic_auth uri.user, uri.password
      end
      if (cfg(:eaccess_user))
        req.add_field 'X-eaccess_userid', cfg(:eaccess_user)
      end
      http.request(req).body
    rescue Exception => e
      return "#{e.class}: #{e.message}"
    end
  end

  def rollback
    if (cfg(:rollback))
      Bundler.ui.warn "Warning: Rolling back to previous release"
      hosts.each do |host|
        Net::SSH.start(host, user) do |ssh|
          stop_host(host)
          ssh.exec!("mv #{prefix}/apps/#{name}/#{name}.jar.previous #{prefix}/apps/#{name}/#{name}.jar")
          start_host(host)
        end
      end
    else
      Bundler.ui.warn "Rollback is disabled for #{environment}. Perform manual rollback."
    end
  end

  def user_verifies_operation_for_production_environment(operation)
    if not cfg(:production_environment)
      return true
    end

    random_number = rand(50) + 1 # to avoid 0 which is default error handling of doing to_i

    Bundler.ui.warn "Do you really want to #{operation} to production environment? Input following number to comply: #{random_number}"

    random_number == STDIN.gets.to_i
  end
end

DeployHelper.install_tasks

Dir["#{File.dirname(__FILE__)}/*/Rakefile"].each { |f| load f }