object @ack

attributes :id, :score

child :item => :item do
  attributes :id, :external_uid, :path
end
