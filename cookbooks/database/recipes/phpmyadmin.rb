# phpmyadmin.rb
if node != nil && node['config'] != nil
  db_user = node['config']['db_user'] || "wordpress"
  db_pswd = node['config']['db_pswd'] || "wordpress"
  db_ip   = node['config']['db_ip'] || "127.0.0.1"
  wp_ip   = node['config']['wp_ip'] || "127.0.0.1"
else
  db_user = "wordpress"
  db_pswd = "wordpress"
  db_ip   = "127.0.0.1"
  wp_ip   = "127.0.0.1"
end
# Instalar Apache
package 'apache2' do
  action :install
end

#Iniciar apache
service 'apache2' do
  action [:enable, :start]
end

# Instala los paquetes necesarios para phpMyAdmin
package 'php'
package 'php-mbstring'
package 'php-zip'
package 'php-gd'
package 'php-json'
package 'php-mysql'
package 'apache2'
package 'phpmyadmin'

# Configuración básica de Apache para phpMyAdmin
bash 'enable_phpmyadmin' do
  code <<-EOH
    echo 'Include /etc/phpmyadmin/apache.conf' >> /etc/apache2/apache2.conf
    systemctl restart apache2
  EOH
  not_if "grep -q 'Include /etc/phpmyadmin/apache.conf' /etc/apache2/apache2.conf"
end

# Configurar la IP del servidor MySQL, el usuario y la contraseña en phpMyAdmin
ruby_block 'configure_phpmyadmin' do
  block do
    file = Chef::Util::FileEdit.new('/etc/phpmyadmin/config.inc.php')
    file.insert_line_if_no_match(
      /$cfg\['Servers'\]\[\$i\]\['host'\]/,
      "$cfg['Servers'][$i]['host'] = 'db.epnewman.edu.pe';"
    )
    file.insert_line_if_no_match(
      /$cfg\['Servers'\]\[\$i\]\['user'\]/,
      "$cfg['Servers'][$i]['user'] = 'wordpress';"
    )
    file.insert_line_if_no_match(
      /$cfg\['Servers'\]\[\$i\]\['password'\]/,
      "$cfg['Servers'][$i]['password'] = 'wordpress';"
    )
    file.insert_line_if_no_match(
      /$cfg\['Servers'\]\[\$i\]\['auth_type'\]/,
      "$cfg['Servers'][$i]['auth_type'] = 'cookie';"
    )
    file.insert_line_if_no_match(
      /$cfg\['Servers'\]\[\$i\]\['connect_type'\]/,
      "$cfg['Servers'][$i]['connect_type'] = 'tcp';"
    )

    file.write_file
  end
end