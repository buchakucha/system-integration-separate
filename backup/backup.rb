#!/usr/bin/env ruby
require 'optparse'

def check_data(path_dir, path_backup, action)
    unless (File.exist?(File.expand_path(path_dir)))
      puts "Введенной директории с проектом не существует, проверьте правильность ввода данных"
      exit(1)
    end
  
    unless (File.exist?(File.expand_path(path_backup)))
      puts "Введенной директории с backup-архивом не существует, проверьте правильность ввода данных"
      exit(1)
    end

    unless (action == "zip" || action == "unzip")   
        puts "Действия \"#{action}\" не существует, возможны два действия: zip или unzip"
        exit(1)
    end
end

def run(*args, dir: nil)
    command = args.join(' ')
    if !dir.nil?
      command = "cd #{dir} && #{command}"
    end
    puts "Выполняется команда #{command}"
    system(command)
end

def action(path_dir, path_back, action)
    archive = nil
    absolute_path_dir = File.expand_path(path_dir)
    absolute_path_back = File.expand_path(path_back)
    if action == "zip"
        time = Time.new
        archive = "backup-#{time.strftime("%d_%m_%Y_%H_%M_%S")}.tar"
        puts "Создание архива \"#{archive}\""
        if !File.exist?(File.join(absolute_path_back, archive))
        run('sudo', 'rm', '-rf','/tmp/last_backup/')
        run('sudo', 'mkdir', '/tmp/last_backup/')
        run('sudo', 'cp', '-r', File.join(absolute_path_dir, 'taiga-docker', 'data'), '/tmp/last_backup/taiga-docker/')
        run('sudo', 'cp', '-r', File.join(absolute_path_dir, 'jenkins', 'data'), '/tmp/last_backup/jenkins/') 
        run('sudo', 'tar', '-cvf', File.join(absolute_path_back, archive), '/tmp/last_backup/')
        run('sudo', 'rm', '-rf', '/tmp/last_backup')
    end
    elsif action == "unzip"
      puts("Введите название архива с расширением tar, которое необходимо распаковать (например, backup.tar)")
      archive = gets.chomp
      if File.exist?(File.join(absolute_path_back, archive))
        run('sudo', 'rm', '-rf', File.join(absolute_path_dir, 'taiga-docker', 'data'))
        run('sudo', 'rm', '-rf', File.join(absolute_path_dir,'jenkins','data'))
        run('sudo', 'tar', '-xvf', File.join(absolute_path_back, archive), '-C', File.join(absolute_path_dir, 'backup'))
        run('sudo', 'cp', '-r', File.join(absolute_path_dir, 'backup', 'tmp', 'last_backup', 'taiga-docker'), File.join(absolute_path_dir, 'taiga-docker', 'data'))
        run('sudo', 'cp', '-r', File.join(absolute_path_dir, 'backup', 'tmp', 'last_backup', 'jenkins'), File.join(absolute_path_dir, 'jenkins', 'data'))
        run('sudo', 'rm', '-rf', File.join(absolute_path_dir, 'backup', 'tmp'))
      else
        puts("Архива с введенным именем не существует, проверьте правильность ввода данных")
        action(path_dir, path_back, action)
      end
    end
end

if __FILE__ == $0
    options = {}
    OptionParser.new do |option|
      option.on('--pathdir PATHDIR') { |o| options[:pathd] = o }
      option.on('--pathbackup PATHBACK') { |o| options[:pathb] = o }
      option.on('--action ACTION') { |o| options[:action] = o }
    end.parse!
    if options.size != 3
      puts "Необходимо ввести три параметра: "
      puts "--pathdir=\"PATH_TO_DIRECTORY\" - путь до директории с проектом"
      puts "--pathbackup=\"PATH_TO_DIRECTORY_WITH_BACKUP\" - путь до директории, в которой будет содержаться backup-архив"
      puts "--action=\"ACTION\" - возможны два действия: zip, чтобы заархивировать данные, unzip - разархивировать"
    exit(1)
    end
    check_data(options[:pathd], options[:pathb], options[:action])
    action(options[:pathd], options[:pathb], options[:action])
end