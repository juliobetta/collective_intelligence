require_relative '../recommendations.rb'
require 'rspec'

describe 'Recommendations' do
   context 'with Euclidean Distance' do
    it 'should give 0 if users have no prefs in common' do
      prefs = {'p1'=> {'value1' => 2.6, 'value2' => 4.5}, 'p2' => {'other1' => 1, 'other2' => 1}}
      Recommendations.sim_distance(prefs, 'p1', 'p2').should == 0
    end

    it 'should give 1 if users have identical prefs' do
      prefs = {'p1'=> {'value1' => 1, 'value2' => 1}, 'p2' => {'value1' => 1, 'value2' => 1}}
      Recommendations.sim_distance(prefs, 'p1', 'p2').should == 1
    end
  end

  context 'with Pearson Correlation Score' do
    it 'should give 1 value if users have identical prefs' do
      prefs = {'p1' => {'value1' => 3.0, 'value2' => 2.0, 'value3' => 1.0},
               'p2' => {'value1' => 3.0, 'value2' => 2.0, 'value3' => 1.0}}
      Recommendations.sim_pearson(prefs, 'p1', 'p2').should == 1
    end

    it 'should give -1 if users have inverse correlation' do
      prefs = {'p1' => {'value1' => 1.0, 'value2' => 2.0, 'value3' => 3.0},
               'p2' => {'value1' => 3.0, 'value2' => 2.0, 'value3' => 1.0}}
      Recommendations.sim_pearson(prefs, 'p1', 'p2').should == -1
    end

    it 'should give 0 if users have no correlation' do
      prefs = {'p1' => {'value1' => 0.0, 'value2' => 0.0, 'value3' => 0.0},
               'p2' => {'value1' => 1.0, 'value2' => 2.0, 'value3' => 1.0}}
      Recommendations.sim_pearson(prefs, 'p1', 'p2').should == 0
    end
  end

  context 'with top_matches' do
    let(:prefs) do
      {'p1' => {'value1' => 2.2, 'value2' => 4.8, 'value3' => 1.0, 'value5' => 6.7, 'value4' => 7.9},
       'p2' => {'value1' => 5.6, 'value2' => 9.9, 'value3' => 3.6, 'value5' => 2.4, 'value4' => 5.6},
       'p3' => {'value1' => 7.9, 'value2' => 8.8, 'value3' => 7.9, 'value5' => 5.9, 'value4' => 1.9},
       'p4' => {'value1' => 8.4, 'value2' => 7.9, 'value3' => 3.0, 'value5' => 9.9, 'value4' => 6.3},
       'p5' => {'value1' => 2.1, 'value2' => 9.8, 'value3' => 5.8, 'value5' => 4.8, 'value4' => 4.7}}
    end

    let(:person) { 'p1' }

    it 'should return the right numbers of items' do
      Recommendations.top_matches(prefs, 'p1', n = 3).length.should == 3
    end

    it 'should match the top result for sim_distance' do
      result = Recommendations.top_matches(prefs, person, n = 3, algorithm = 'sim_distance')
      other  = result.keys.first # get best matched person

      Recommendations.sim_distance(prefs, person, other).should == result.values.first
    end

    it 'should match the top result for sim_pearson' do
      result = Recommendations.top_matches(prefs, person)
      other  = result.keys.first # get best matched person

      Recommendations.sim_pearson(prefs, person, other).should == result.values.first
    end
  end
end