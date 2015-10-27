require 'spec_helper'
require 'bigdecimal'
require 'time'

Riak::Client::BeefcakeProtobuffsBackend.configured?

describe Riak::Client::BeefcakeProtobuffsBackend::TsCellCodec do
  describe 'serializing values' do
    it { is_expected.to serialize("hello", binary_value: "hello") }
    it { is_expected.to serialize(5, integer_value: 5) }
    it { is_expected.to serialize(123.45, double_value: 123.45) }
    it { is_expected.to serialize((2**64),
                                  numeric_value: "18446744073709551616") }
    it do
      is_expected.to serialize(BigDecimal.new("0.1"), numeric_value: "0.1E0")
    end
    it do
      is_expected.to serialize(Time.parse("June 23, 2015 at 9:46:28 EDT"),
                               timestamp_value: 1435067188000)
    end
    it { is_expected.to serialize(true, boolean_value: true) }
    it { is_expected.to serialize(false, boolean_value: false) }
    it { is_expected.to serialize(nil, {}) }

    it 'refuses to serialize complex numbers' do
      expect{ subject.cell_for(Complex(1, 1)) }.
        to raise_error Riak::TimeSeriesError::SerializeComplexNumberError
    end

    it 'refuses to serialize rational numbers' do
      expect{ subject.cell_for(Rational(1, 1)) }.
        to raise_error Riak::TimeSeriesError::SerializeRationalNumberError
    end
  end

  describe 'deserializing values'


  RSpec::Matchers.define :serialize do |measure, options|
    match do |actual|
      serialized = actual.cell_for(measure)
      serialized.to_hash == options
    end

    failure_message do |actual|
      serialized = actual.cell_for(measure)
      "expected #{options}, got #{serialized.to_hash}"
    end

    description do
      "serialize #{measure.class} #{measure.inspect} to TsCell #{options}"
    end
  end
end
