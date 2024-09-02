describe package('phpmyadmin') do
    it { should be_installed }
  end
  
  describe file('/etc/apache2/apache2.conf') do
    its(:content) { should match /Include \/etc\/phpmyadmin\/apache.conf/ }
  end
  
  describe service('apache2') do
    it { should be_running }
  end
  
  describe command('curl http://localhost/phpmyadmin') do
    its(:stdout) { should match /phpMyAdmin/ }
    its(:exit_status) { should eq 0 }
  end
  