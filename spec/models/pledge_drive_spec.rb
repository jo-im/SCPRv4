require "spec_helper"

describe PledgeDrive do
  describe '#happening?' do
    context 'happening now' do
      context 'that is enabled' do
        it 'returns true' do
          create :pledge_drive, :happening, :enabled
          expect(PledgeDrive.happening?).to be true
        end
      end
      context 'that is not enabled' do
        it 'returns false' do
          create :pledge_drive, :happening
          expect(PledgeDrive.happening?).to be false
        end
      end
    end
    context 'no pledge drives are happening' do
      context 'and none exist' do
        it 'returns false' do
          PledgeDrive.delete_all
          expect(PledgeDrive.happening?).to be false
        end
      end
      context 'that are in the past' do
        it 'returns false' do
          create :pledge_drive, :happened, :enabled
          expect(PledgeDrive.happening?).to be false
        end
      end
      context 'that are awaiting' do
        it 'returns false' do
          create :pledge_drive, :will_happen, :enabled
          expect(PledgeDrive.happening?).to be false
        end
      end
    end
  end
end
