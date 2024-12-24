# todo: explain usage / syntax
require "fileutils"

# > class MergeNotes
class MergeNotes
  # >> method read_files
  def self.read_files(file1, file2)

    # f1: original file | f2: appended file
    @f1 = File.readlines(file1)
    @f2 = File.readlines(file2)

    # array containing 2 arrays containing the respective lines of each file.
    # zamn
    @file_lines = Array[@f1, @f2]
  end


  # >> method get_sections
  def self.get_sections
    # first check for metadata
    if @f1[0] == "---\n"
      self.get_yaml(@f1)
    elsif @f2[0] == "---\n"
      self.get_yaml(@f2)
    else
      puts "No YAML found in file header. The output will not include any metadata."
    end

    # go thru f1's lines, then f2
    @file_lines.each_with_index {|f, i1|
      currheadings = {}

      # go thru each line
      f.each_with_index {|line, i2|
        # >>> creating key value pairs of "heading: line #"
        # specifically checking for 2nd level headings (timestamps)
        # "(m)" denotes which headings come from the 2nd file
        if line[0..2] == "## " and i1 == 1
          currheadings["#{line.strip}°\n"] = i2
        elsif line[0..2] == "## "
          currheadings["#{line}"] = i2
        end
      }

      currheadings.each_with_index {|heading, i2|
        # getting line number of the next heading
        next_head_line = currheadings.values[i2 + 1]
        first_line = heading[1] + 1

        # if it's the last heading, it'll include the rest of the array in the
        # section (i.e., the rest of the file). otherwise it uses the next
        # heading to mark the end of the section.
        if next_head_line
          last_line = next_head_line - 1
          @allsections = Array(@allsections) << f[first_line..last_line].unshift(heading[0])
        else
          here_lines = f[heading[1]..-1]
          lastlast_line = here_lines[-1]
          fixed_line = lastlast_line + "\n\n"

          here_lines.pop
          here_lines.push(fixed_line)
          @allsections = Array(@allsections) << f[first_line..last_line].unshift(heading[0])
        end
      }
    }
  end


  # >> method get_yaml
  def self.get_yaml(f)
    yamllines = []

    # check first 10 lines of given file for yaml metadata.
    # having more than that seems kinda excessive but if the need ever arises,
    # just change the number ¯\_(ツ)_/¯
    f[..10].each_with_index {|line, i|
      if line == "---\n"
        yamllines = Array(yamllines) << i
        break if yamllines.length == 2
      end
    }

    @frontmatter = f[yamllines[0]..yamllines[1]]
  end


  # >> method remove_trailing_whitespace
  def self.remove_trailing_whitespace
    @sorted_sections = @allsections.sort
    last_section = @sorted_sections[-1]

    # remove pre-existing whitespace at end of line
    for line in last_section.reverse
      temparray = Array(temparray) << line.rstrip
    end

    blank_lines = 0

    # get # of blank lines are at end of array (or beginning, since it's
    # reversed). if there aren't any(more), then stop.
    temparray.each_with_index {|line, i|
      if line.empty?
        blank_lines = blank_lines + 1
      end
      break unless line.empty?
    }

    # coming back later: i genuinely don't remember why i did it this way,
    # couldn't you just delete the blank lines as you come across them?? why go
    # to the extra effort of having the blank_lines counter?
    # i have to assume i tried doing that and it didn't work though.

    # delete blank lines
    blank_lines.times do
      temparray.delete_at(0)
    end

    # add "\n" back to the end of each line, except for the last. (no extra
    # line at end of file)
    for line in temparray
      unless line == temparray.first
        fixed_line = line + "\n"
        @newarray = Array(@newarray) << fixed_line
      else
        @newarray = Array(@newarray) << line
      end
    end

    # replace last_section with stripped version
    @sorted_sections.pop
    @sorted_sections.push(@newarray.reverse)

    unless @sorted_sections[-2][-2..-1].join.include? "\n\n"
      @sorted_sections[-2].push("\n\n")
    end
  end


  # >> method write_to_file
  def self.write_to_file
    # uses same name as ARGV[0]
    foutput = File.new(File.join("output", @file1.split("/")[1..-1]), "w")

    if @frontmatter
      # adds frontmatter to beginning of data, if found
      @sorted_sections.insert(0, @frontmatter)
    end

    for section in @sorted_sections
      for line in section
        foutput.write(line)
      end
    end

    foutput.close
    puts "File created at output/#{@file1}."
  end


  def self.do_it(f1, f2)
    # and then all the functions in order. :)
    # probably also not the Most Proper way of doing things idk
    self.read_files(f1, f2)
    self.get_sections
    self.remove_trailing_whitespace
    self.write_to_file
  end

  if ARGV[0..1].include? "-d"
    # merge directories instead of files
    dir1 = Dir[ARGV[1] + "/**/*.md"]
    dir2 = Dir[ARGV[2] + "/**/*.md"]

    dir1.each_with_index {| f1, i1 |
      @s1 = f1.split("/")[1..-1]

      dir2.each_with_index {| f2, i2 |
        @s2 = f2.split("/")[1..-1]

        if @s1 == @s2
          @file1 = dir1[i1]
          @file2 = dir2[i2]

          if @s1.length > 2
            # if the file is nested within a subfolder of the given directory
            dirname = File.join("output", @s1[0..-2])
          else
            dirname = File.join("output", @s1[-2])
          end

          begin
            FileUtils::mkdir_p(dirname)
          rescue Errno::EEXIST
            # todo: there's gotta be a better way of doing this right? not
            # having to worry about the error if the dir already exists
          ensure
            puts "merging: #{f1} #{f2}"
            `ruby merge.rb #{f1} #{f2}`
          end
        end
      }
    }
  else
    @file1 = ARGV[0]
    @file2 = ARGV[1]
  end


  # if ARGV[0..1].include? "-h"
    # todo: "secondary" headers -- ability to toggle the symbol, maybe use a custom one?
  # end


  do_it(@file1, @file2)
end
