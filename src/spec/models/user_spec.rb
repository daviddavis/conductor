require 'spec_helper'

describe User do
  before(:each) do
  end

  it "should create a new user 'tuser'" do
    user = Factory.create(:tuser)
    user.should be_valid
  end

  it "should require password confirmation" do
    user = Factory.build :tuser
    user.should be_valid
    user.password_confirmation = "different password"
    user.should_not be_valid
  end

  it "should require unique login" do
    user1 = Factory.create(:tuser)
    user2 = Factory.create(:tuser)
    user1.should be_valid
    user2.should be_valid

    user2.login = user1.login
    user2.should_not be_valid
  end

  #it "should require unique email" do
  #  user1 = Factory.create(:tuser)
  #  user2 = Factory.create(:tuser)
  #  user1.should be_valid
  #  user2.should be_valid

  #  user2.email = user1.email
  #  user2.should_not be_valid
  #end

  #it "should requive valid email" do
  #  user = User.new(Factory.attributes_for(:tuser))

  #  user.email = "invalid-email"
  #  user.should_not be_valid
  #end

  it "should not be valid if first name is too long" do
    u = FactoryGirl.create(:tuser)
    u.first_name = ('a' * 256)
    u.valid?.should be_false
    u.errors[:first_name].first.should_not be_nil
    u.errors[:first_name].first.should =~ /^is too long.*/
  end

  it "should not be valid if last name is too long" do
    u = FactoryGirl.create(:tuser)
    u.last_name = ('a' * 256)
    u.valid?.should be_false
    u.errors[:last_name].first.should_not be_nil
    u.errors[:last_name].first.should =~ /^is too long.*/
  end

  it "should require quota to be set" do
    user = FactoryGirl.create :tuser
    user.should be_valid

    user.quota = nil
    user.should_not be_valid
  end

  it "should encrypt password when a user is saved" do
    user = FactoryGirl.build :tuser
    user.crypted_password.should be_nil
    user.save!
    user.crypted_password.should_not be_nil
  end


  it "should authenticate a user with valid password" do
    user = FactoryGirl.create :tuser
    User.authenticate(user.login, user.password).should_not be_nil
  end

  it "should not authenticate a user with valid password" do
    user = FactoryGirl.create :tuser
    User.authenticate(user.login, 'invalid').should be_nil
  end

  it "should authenticate a user against LDAP and create local user w/o password" do
    Ldap.should_receive(:valid_ldap_authentication?).and_return(true)
    User.authenticate_using_ldap('ldapuser', 'random').should_not be_nil
    u = User.find_by_login('ldapuser')
    u.should_not be_nil
    u.crypted_password.should be_nil
  end

  it "should authenticate a user against LDAP and return existing user" do
    user = FactoryGirl.create(:tuser, :ignore_password => true, :password => nil)
    Ldap.should_receive(:valid_ldap_authentication?).and_return(true)
    u = User.authenticate_using_ldap(user.login, 'random')
    u.should_not be_nil
    u.id.should == user.id
  end

end
