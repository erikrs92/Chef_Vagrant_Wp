require 'spec_helper'

describe 'database::phpmyadmin' do
  it 'installs the phpmyadmin package' do
    expect(package('phpmyadmin')).to be_installed
  end

  it 'includes phpmyadmin configuration in apache2' do
    expect(file('/etc/apache2/apache2.conf')).to contain('Include /etc/phpmyadmin/apache.conf')
  end

  it 'restarts apache2 service' do
    expect(service('apache2')).to be_running
  end
end
