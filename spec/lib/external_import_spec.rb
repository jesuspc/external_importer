require 'spec_helper'
require_relative '../../lib/external_import'

describe ExternalImport do
  describe "Initialization" do
    subject { ExternalImport.new :json }

    it "gets initialized" do 
      subject.class.should eq ExternalImport
    end

    it "sets the format instance variable" do 
      subject.instance_variable_get( '@format' ).should eq :json
    end

    context "when called with source option" do 
      let( :options ) { double }
      before { options.stub( :[] ).with( :source ).and_return "test_source" }
      subject { ExternalImport.new :json, options }

      it "sets the source instance variable" do
        subject.instance_variable_get( '@source' ).should eq options[ :source ]
      end
    end
  end

  describe "#from" do 
    let( :source ) { double }
    subject { ExternalImport.new( :json ).from source }

    it "fills the source instance variable with the given input" do 
      subject.instance_variable_get( '@source' ).should eq source
    end

    it "returns itself" do
      subject.class.should eq ExternalImport
    end
  end

  describe "#with" do 
    let( :options ) { double :to_param => "testparam" }
    subject { ExternalImport.new( :json ).with options }

    it "returns itself" do
      subject.instance_variable_get( '@content' ).should eq options.to_param
    end

    context "when called just with options" do 
      let( :options ) { double :to_param => "testparam" }
      subject { ExternalImport.new( :json ).with options }

      it "sets the content instance variable with the options as params" do 
        subject.instance_variable_get( '@content' ).should eq options.to_param
      end
    end

    context "when called just with a block" do 
      let( :options ) { double :to_param => "testparam" }
      subject { ExternalImport.new( :json ).with { options } }
      
      it "sets the content instance variable with the block return as params" do 
        subject.instance_variable_get( '@content' ).should eq options.to_param
      end
    end

    context "when called with a block and options" do 
      let( :options   ) { double :to_param => "testparam"  }
      let( :options_2 ) { double :to_param => "testparam2" }
      subject { ExternalImport.new( :json ).with( options_2 ) { options } }
      
      it "sets the content instance variable with the block return as params" do 
        subject.instance_variable_get( '@content' ).should eq options.to_param
      end
    end
  end

  describe "#import" do 
    let( :object_receiver_hash ) { { :objects => :receivers } }
    let( :options  ) { double }
    let( :response ) { { :body => 'thebody', :status => 200 } }
    let( :url_object ) do
      double :host => 'endpoint.test',
             :port => '3000',
             :to_s => 'http://endpoint.test'
    end

    subject { ExternalImport.new :json, :source => "http://endpoint.test" }

    before do
      stub_request( :get, 'http://endpoint.test/' ).to_return response

      String.any_instance.stub_chain( :classify, :constantize ).
      and_return JsonImporter

      subject.class.const_set( 'JsonImporter', double )
    end

    context "without block given" do
      it "performs the request and imports the body of the result" do
        JsonImporter.should_receive( :import ).
        with kind_of( Net::HTTPOK ), :objects, :receivers, options

        subject.import object_receiver_hash, options
      end
    end

    context "when block given" do
      let( :block ) { double }

      it "performs the request and imports the body of the result" do
        JsonImporter.should_receive( :import ).
        with kind_of( Net::HTTPOK ), :objects, :receivers, options

        subject.import object_receiver_hash, options do
          block
        end
      end
    end
  end
end