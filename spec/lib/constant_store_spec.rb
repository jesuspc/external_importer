require 'spec_helper'
require_relative '../../lib/constant_store'

class DummyClass
end

describe ConstantStore do
  before { ConstantStore.const_set 'STORED_CONSTANT_NAME', nil }
  let(:dummy_class) { Class.new { extend ConstantStore } }

  describe 'ClassMethods module' do
    describe '#constant_store class method' do
      before { dummy_class.constant_stores :test_constant, :as => :hash }
      
      it 'stores the options[ :as ] as a module instance variable' do
        ConstantStore.instance_variable_get( '@constant_class' ).
        should eq :hash 
      end
      it 'stores the constant name as a module constant' do
        ConstantStore.const_get( 'STORED_CONSTANT_NAME' ).
        should eq 'TEST_CONSTANT' 
      end
      it 'sets the constant to the base class initialized as expected' do
        dummy_class.const_get( 'TEST_CONSTANT' ).should eq Hash.new 
      end
    end
  end

  describe 'InstanceMethods' do
    before { dummy_class.constant_stores :test_constant, :as => :hash }

    describe '#import_endpoints' do
      subject { dummy_class.new }

      context 'when a hash input' do
        let( :endpoints ) do
          { :endpont_1 => "endpoint", :endpont_2 => "endpoint" }
        end
        before  { subject.class.import_constant( endpoints ) }

        it 'sets the class variable with the provided endpoints' do
          subject.class.const_get( 'TEST_CONSTANT' ).should eq endpoints
        end
      end

      context 'when endpoints input is not a hash' do
        let( :endpoints ) { "enpoints as string" }

        it 'raises a UnprocessableEndpoints error' do
          expect{ subject.class.import_constant endpoints }.
          to raise_error( ConstantStore::UnprocessableEndpoints )
        end
      end
    end
  end
end