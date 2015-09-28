# encoding: utf-8
require 'spec_helper'

describe String do
  describe :i18n_transliterate do
    it 'should use I18n.transliterate' do
      expect('Ærøskøbing'.i18n_transliterate).to eq('AEroskobing')
      expect('Jürgen'.i18n_transliterate).to eq('Jurgen')
    end
  end
end
