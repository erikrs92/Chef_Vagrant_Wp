Vagrant.configure("2") do |config|
    config.env.enable              # Habilitamos vagrant-env(.env) 
    config.vm.boot_timeout = 600
    if ENV['TESTS'] == 'true'
        config.vm.define "test" do |testing|
            testing.vm.box = "gutehall/ubuntu24-04"  # Utilizamos una imagen de Ubuntu 20.04 por defecto
            testing.vm.box_version = "2024.08.30" 
            testing.vm.provision "shell", inline: <<-SHELL
                # Instalar ChefDK
                wget -qO- https://omnitruck.chef.io/install.sh | sudo bash -s -- -P chefdk

                export CHEF_LICENSE="accept"

                # Instalar las gemas necesarias para las pruebas
                cd /vagrant/cookbooks/database && chef exec bundle install
                cd /vagrant/cookbooks/wordpress && chef exec bundle install
                cd /vagrant/cookbooks/proxy && chef exec bundle install

                chown -R vagrant:vagrant /opt/chefdk
            SHELL
        end
    else
        config.vm.define "database" do |db|
            db.vm.box = "gutehall/ubuntu24-04"  # Utilizamos una imagen de Ubuntu 20.04 por defecto
            db.vm.box_version = "2024.08.30"
            db.vm.hostname = "db.epnewman.edu.pe"
            db.vm.network "public_network", ip: ENV["DB_IP"]
            db.vm.provider "vmware_workstation" do |dbs| 
                dbs.memory = "2048"
                dbs.cpus = 2
            end
            db.vm.provision "chef_solo" do |chef| 
                chef.install = "true"
                chef.arguments = "--chef-license accept"
                chef.add_recipe "database" 
                chef.add_recipe "database::phpmyadmin"
                chef.json = {
                    "config" => {
                        "db_ip" => "#{ENV["DB_IP"]}",
                        "wp_ip" => "#{ENV["WP_IP"]}",
                        "db_user" => "#{ENV["DB_USER"]}",
                        "db_pswd" => "#{ENV["DB_PSWD"]}"
                    }
                }
            end
        end

        config.vm.define "wordpress" do |sitio|
            sitio.vm.box = "gutehall/ubuntu24-04"  # Utilizamos una imagen de Ubuntu 20.04 por defecto
            sitio.vm.box_version = "2024.08.30"
            sitio.vm.hostname = "wordpress.epnewman.edu.pe" 
            sitio.vm.network  "public_network", ip: ENV["WP_IP"]
            sitio.vm.provider  "vmware_workstation"
            sitio.vm.provision  "chef_solo" do |chef|
                chef.install = "true"
                chef.arguments = "--chef-license accept"
                chef.add_recipe "wordpress"
                chef.json = {
                    "config" => {
                        "db_ip" => "#{ENV["DB_IP"]}",
                        "db_user" => "#{ENV["DB_USER"]}",
                        "db_pswd" => "#{ENV["DB_PSWD"]}" 
                    }
                }
           # Provisión de Shell para ejecutar el comando de instalación de WordPress
            sitio.vm.provision "shell", inline: <<-SHELL
                sudo -u vagrant -i -- wp core install --path="/opt/wordpress/" --url="#{ENV['PROXY_IP']}" --title="EPNEWMAN - Herramientas de automatización de despliegues" --admin_user=admin --admin_password="Epnewman123" --admin_email="admin@epnewman.edu.pe"
            SHELL
            end
        end

        config.vm.define "proxy" do |proxy|
            proxy.vm.box = "gutehall/ubuntu24-04"  # Utilizamos una imagen de Ubuntu 20.04 por defecto
            proxy.vm.box_version = "2024.08.30"
            proxy.vm.hostname = "proxy.epnewman.edu.pe"
            proxy.vm.network "public_network", ip: ENV["PROXY_IP"]
            proxy.vm.provider "vmware_workstation"
            proxy.vm.provision "chef_solo" do |chef|
                chef.install = "true"
                chef.arguments = "--chef-license accept"
                chef.add_recipe "proxy"
                chef.json = {
                    "config" => {
                        "wp_ip" => "#{ENV["WP_IP"]}"
                    }
                }
            end
        end
    end
end