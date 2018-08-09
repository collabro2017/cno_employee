class FieldCaption < String

  #TO-DO: Create specs for this class instead of testing it in field_spec.rb

	EXPANSIONS = {
    #Two letter
    "hh"     => "Household",
    "st"     => "Street",
    "yr"     => "Year",

    #Three letter
    "biz"    => "Business",
    "cel"    => "Celular",
    "cra"    => "Community Reinvestment Act",
    "est"    => "Estimated",
    "lat"    => "Latitude",
    "lon"    => "Longitude",
    "ltv"    => "Loan to Value",
    "msa"    => "Metropolitan Statistical Area",
    "num"    => "Number",
    "opp"    => "Opportunity",
    "pwc"    => "Personal Watercraft",
    "std"    => "Standard",
    "yrs"    => "Years",

    #Four letter
    "dpbc"   => "Delivery Point Bar Code",
    "misc"   => "Miscellaneous",
    "plus"   => "Plus",
  }

  ACRONYMS = {
    "diy" => "DIY",
    "dvd" => "DVD",
    "dvds" => "DVDs",
    "hdtv" => "HDTV",
    "hdtvs" => "HDTVs",
    "tv" => "TV",
    "tvs" => "TVs"
  }

  def self.generate(name)
    caption = expand(name, '_')
    caption = replace_apostrophe(caption, '_')
    caption.titleize!
    capitalize_acronyms(caption)  
  end


	def self.expand(text, separator=' ')
		replace_using_dictionary(text, EXPANSIONS, separator)
	end

	def self.capitalize_acronyms(text, separator=' ')
		replace_using_dictionary(text, ACRONYMS, separator)
	end
	
	def self.replace_apostrophe(text, separator)
	  regexp = Regexp.new("(\\A|#{separator})apos(\\Z|#{separator})",
	  		Regexp::IGNORECASE)
	  text.gsub(regexp,"'")
	end

	def self.replace_using_dictionary(text, dictionary, separator=' ')
		dictionary.each do |key, value|
 			regexp = Regexp.new("(\\A|#{separator})#{key}(\\Z|#{separator})",
	  			Regexp::IGNORECASE)
			text = text.gsub(regexp, "\\1#{value}\\2")
		end

		text
	end

  private_class_method :expand, :capitalize_acronyms, :replace_apostrophe,
      :replace_using_dictionary

end
