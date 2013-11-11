class Section

  include Mongoid::Document

  embedded_in :article

end
