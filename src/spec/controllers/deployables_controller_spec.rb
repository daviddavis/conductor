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

require 'spec_helper'

describe DeployablesController do

  fixtures :all
  before do
    @admin_permission = FactoryGirl.create :admin_permission
    @admin = @admin_permission.user
    mock_warden(@admin)
  end

  describe "#create" do
    before(:each) do
      @image = mock(Aeolus::Image::Warehouse::Image, :id => '3c58e0d6-d11a-4e68-8b12-233783e56d35', :name => 'image1', :uuid => '3c58e0d6-d11a-4e68-8b12-233783e56d35')
      Aeolus::Image::Warehouse::Image.stub(:find).and_return(@image)
    end

    it "creates new deployable from image via UI" do
      get :new, :create_from_image => @image.id
      response.should be_success
      response.should render_template("new")
    end

    it "creates new deployable from image via POST" do
      hw_profile = FactoryGirl.create(:front_hwp1)
      catalog = FactoryGirl.create(:catalog)
      post(:create, :create_from_image => @image.id, :deployable => {:name => @image.name}, :hardware_profile => hw_profile.id, :catalog_id => catalog.id)
      response.should redirect_to(catalog_url(catalog.id))
    end
  end

  describe "#destroy" do
    before do
      @deployable = stub_model(Deployable, :name => "test_delete", :id => 1)
      Deployable.stub(:find).and_return(@deployable)
    end


    context "deletion successfully" do
      before do
        Deployable.any_instance.stub(:destroy).and_return(true)
      end

      it "deletes a deployable and redirect to deployables#index" do
        delete :destroy, :id => @deployable.id
        response.should redirect_to deployables_path
      end

      it "deletes a deployable and appears flash notice" do
        delete :destroy, :id => @deployable.id
        flash[:notice].should eql("Deployable test_delete delete successfully!")
      end
    end

    context "deletion fails" do
      before do
        Deployable.any_instance.stub(:destroy).and_return(false)
      end

      it "not delete a deployable and redirect to deployables#show" do
        delete :destroy, :id => @deployable.id
        response.should redirect_to deployables_path
      end

      it "not delete a deployable and shows flash error" do
        delete :destroy, :id => @deployable.id
        flash[:error].should eql("Deployable test_delete delete failed!")
      end
    end
  end

  describe "#multi_destroy" do
    it "redirects to deployables#index" do
        delete :multi_destroy
        response.should redirect_to deployables_path
      end

    context "with params[:deployables_selected]" do
      before do
        @deployable1 = Factory :deployable, :name => "test_delete"
        @deployable2 = Factory :deployable, :name => "test_delete2"
      end

      it "deletes both deployables and shows flash notice" do
        delete :multi_destroy, :deployables_selected => [@deployable1.id, @deployable2.id]
        flash[:notice].should eql("2 deployables #{@deployable1.name}, #{@deployable2.name} were deleted!")
      end

      it "not delete deployable1 but not deployable2 and shows flash notice and error" do
        Deployable.any_instance.stub(:destroy).and_return(false)
        delete :multi_destroy, :deployables_selected => [@deployable1.id, @deployable2.id]
        flash[:error].should eql("2 deployables #{@deployable1.name}, #{@deployable2.name} were not deleted!")
      end
    end

    context "without params[:deployables_selected]" do
      it "not delete a deployable and shows flash error" do
        delete :multi_destroy
        flash[:error].should eql("No deployable was not selected!")
      end
    end
  end

end
