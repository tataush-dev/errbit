describe systemd_service('errbit') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe port(3000) do
  it { should be_listening }
end 

describe http('http://127.0.0.1:3000/users/sign_in') do
  its('body') { should include 'Sign in' }
end
 
