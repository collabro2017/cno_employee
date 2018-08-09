
ALIAS_DICTIONARY = {
  "_apos_" => { long:"'" },
  "biz"    => { long:"Business" },
  "cel"    => { long:"Celular" },
  "cra"    => { long:"Community Reinvestment Act"    , short: "CRA" },
  "diy"    => { long:"Do It Yourself"                , short: "DIY" },
  "dpbc"   => { long:"Delivery Point Bar Code"       , short: "DPBC" },
  "dvd"    => { long:"DVD" },
  "est"    => { long:"Estimated" },
  "hdtv"   => { long:"HDTV" },
  "hh"     => { long:"Household"                     , short: "HH" },
  "lat"    => { long:"Latitude"                      , short: "Lat" },
  "lon"    => { long:"Longitude"                     , short: "Lon" },
  "ltv"    => { long:"Loan to Value"                 , short: "LTV" },
  "mh"     => { long:"Mobile Home" },
  "misc"   => { long:"Miscellaneous"                 , short: "Misc" },
  "msa"    => { long:"Metropolitan Statistical Area" , short: "MSA" },
  "num"    => { long:"Number" },
  "opp"    => { long:"Opportunity" },
  "plus"   => { long:"Plus"                          , short: "+"},
  "pwc"    => { long:"Personal Watercraft"           , short: "PWC" },
  "st"     => { long:"Street" },
  "std"    => { long:"Standard" },
  "tv"     => { long:"Television"                    , short: "TV" },
  "yr"     => { long:"Year"}
}


File.open("Std Field Names.txt", "w") do |ofile|

  File.open("Field Names.txt", "r") do |file|

    file.each_line do |line|

      line.strip!

      # 2) Replace words
      @dictionary.each do |key, value|
        value.values.each do |text|  
          line.gsub!(text, key)
        end
      end

      result = line.gsub(' ','_').downcase
      ofile.puts result

    end

  end

end
