#
#   Copyright 2011 Red Hat, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

class CreateCredentialDefinitions < ActiveRecord::Migration
  def self.up
    create_table :credential_definitions do |t|
      t.string :name
      t.string :label
      t.string :input_type
      t.integer :provider_type_id

      t.timestamps
    end
    initialize_table
  end

  def self.down
    drop_table :credential_definitions
  end

  def self.initialize_table
    if CredentialDefinition.all.empty?
      ProviderType.all.each do |provider_type|
        unless provider_type.codename == 'ec2'
          CredentialDefinition.create!(:name => 'username', :label => 'API Key', :input_type => 'text', :provider_type_id => provider_type.id)
          CredentialDefinition.create!(:name => 'password', :label => 'Secret', :input_type => 'password', :provider_type_id => provider_type.id)
        else
          #for ec2 provider type
          CredentialDefinition.create!(:name => 'username', :label => 'Username', :input_type => 'text', :provider_type_id => provider_type.id)
          CredentialDefinition.create!(:name => 'password', :label => 'Password', :input_type => 'password', :provider_type_id => provider_type.id)
          CredentialDefinition.create!(:name => 'account_id', :label => 'AWS Account ID', :input_type => 'text', :provider_type_id => provider_type.id)
          CredentialDefinition.create!(:name => 'x509private', :label => 'EC2 x509 private key', :input_type => 'file', :provider_type_id => provider_type.id)
          CredentialDefinition.create!(:name => 'x509public', :label => 'EC2 x509 public key', :input_type => 'file', :provider_type_id => provider_type.id)
        end
      end
    end
  end
end
