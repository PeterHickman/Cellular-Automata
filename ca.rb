#!/usr/bin/ruby

class CA
  BOUNDARY_CIRCULAR = 1
  BOUNDARY_MISSING = 2

  ALPHABET = '0123456789abcdefghijklmnopqrstuvwxyz'.freeze

  def initialize(base = 2, neighbours = 1, boundary = BOUNDARY_MISSING)
    #  First validate the input

    raise 'Base must be between 2 and 36' unless (2..36).cover?(base)

    raise 'Neighbours must be between 1 and 5' unless (1..5).cover?(neighbours)

    raise 'Boundary must be BOUNDARY_CIRCULAR or BOUNDARY_MISSING' if boundary != BOUNDARY_CIRCULAR && boundary != BOUNDARY_MISSING

    # Ok, set the values in stone

    @base = base
    @neighbours = neighbours
    @boundary = boundary

    # Some derived values

    @neighbourhood = (@neighbours * 2) + 1

    @minstate = 0
    @totalstates = (base**@neighbourhood)
    @maxstate = @totalstates - 1

    @minrule = 0
    @totalrules = (base**@totalstates)
    @maxrule = @totalrules - 1

    # Some place holders for other values

    @rulenr = nil
    @rulestring = nil
    @rulevalid = nil

    @states = {}

    @seed = nil
  end

  def info
    puts "Base is #{@base}"
    puts "Neighbours are #{@neighbours}"
    puts "There are #{@totalstates} states, from #{@minstate} to #{@maxstate}"
    puts "There are #{@totalrules} rules, from #{@minrule} to #{@maxrule}"
    puts "The alphabet is '#{ALPHABET[0...@base]}'"

    if @rulenr
      puts "Rule is #{@rulenr} = '#{@rulestring}' (#{@rulevalid})"

      puts 'States:'
      @maxstate.downto(@minstate) do |n|
        x = convertto(n, @neighbourhood)
        puts "  #{n}:#{x} => #{@states[x]}"
      end
    end

    puts "The seed string is '#{@seed}'" if @seed
  end

  def rulenumber(value)
    raise "Rule must be between 0 and #{@maxrule}" unless (0..@maxrule).cover?(value)

    @rulenr = value
    @rulestring = convertto(value, @totalstates)

    # Build the state table from the rule
    x = 0
    @maxstate.downto(@minstate) do |n|
      @states[convertto(n, @neighbourhood)] = @rulestring[x, 1]
      x += 1
    end

    @rulevalid = validrule
  end

  def rulestring(string)
    string.each_byte do |i|
      raise "Rule string contains non alphabet character '#{i.chr}'" unless ALPHABET[0...@base].cover?(i.chr)
    end

    rulenumber(convertfrom(string))
  end

  def seed(string)
    string.each_byte do |i|
      raise "Seed string contains non alphabet character '#{i.chr}'" unless ALPHABET[0...@base].cover?(i.chr)
    end

    @seed = string
  end

  def centreseed(length)
    raise 'The length of a seed should be greater than 1' if length < 2

    result = '0' * length

    bittoset = (length / 2).to_i

    result[bittoset] = '1'

    @seed = result
  end

  def randomseed(length, density)
    raise 'The length of a seed should be greater than 1' if length < 2

    raise 'The density of a seed should be between 0.0 and 1.0' if density < 0.0 || density > 1.0

    result = '0' * length

    bitstoset = (length * density).to_i

    selectionrange = @base == 2 ? -1 : @base - 1

    while bitstoset != 0
      y = rand(length)

      if result[y] == '0'
        result[y] = selectionrange == -1 ? ALPHABET[1] : ALPHABET[rand(selectionrange + 1)]
        bitstoset -= 1
      end
    end

    @seed = result
  end

  def iterate
    newseed = ''

    (0...@seed.length).each do |n|
      newseed << newvalue(n)
    end

    @seed = newseed
  end

  private

  def newvalue(index)
    state = ''

    nrange(index).each do |n|
      state << (n == -1 ? '0' : @seed[n])
    end

    @states[state]
  end

  def nrange(index)
    lower = index - @neighbours
    upper = index + @neighbours

    result = []

    if @boundary == BOUNDARY_MISSING
      (lower..upper).each do |value|
        result << ((0...@seed.length).cover?(value) ? value : -1)
      end
    else
      (lower..upper).each do |value|
        result << (value % @seed.length)
      end
    end

    result
  end

  def convertto(value, size)
    result = '0' * size

    x = 0
    x += 1 until value <= @base**x

    y = value
    until x < 0
      z = 0
      quitloop = false
      while quitloop == false
        if @base**x <= y
          y -= @base**x
          z += 1
        else
          quitloop = true
        end
      end
      result << ALPHABET[z]
      x -= 1
    end

    result[-size..-1]
  end

  def convertfrom(string)
    result = 0

    string.each_byte do |n|
      result = (result * @base) + ALPHABET.index(n.chr)
    end

    result
  end

  def validrule
    @states.each_key do |k|
      r = k.reverse
      return 'Invalid - Symetry' if @states[k] != @states[r]
    end

    return 'Invalid - Spontainious generation' if @states[convertto(0, @neighbourhood)] != '0'

    'Valid'
  end
end

if $PROGRAM_NAME == __FILE__
  x = CA.new(2, 1, CA::BOUNDARY_CIRCULAR)
  x.rulenumber(90)
  myseed = x.centreseed(61)
  x.info

  puts
  puts '%3d : %s' % [0, myseed]
  (1..30).each do |n|
    puts '%3d : %s' % [n, x.iterate]
  end
end
