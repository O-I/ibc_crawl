class AddContribPackages < ActiveRecord::Migration
  def change
    enable_extension 'pg_trgm'
    enable_extension 'unaccent'
    enable_extension 'fuzzystrmatch'
  end
end
