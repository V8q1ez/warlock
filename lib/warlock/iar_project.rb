require 'pathname'

class IarProject
    attr_accessor :filepath
    attr_accessor :projectdirectory
    attr_accessor :srcfiles
    attr_accessor :headerfiles
    attr_accessor :asmfiles
 
    def initialize(filepath: '')
        @filepath = filepath
        @projectdirectory = File.dirname(filepath)
        @srcfiles = Array.new()
        @headerfiles = Array.new()
        @asmfiles = Array.new()
        read_data_from_file()
    end
 
    def add_source_file(referencefile: '', expectedclosenesslevel: 1)
      normalizedReferencePath = Pathname.new(referencefile).cleanpath
      referenceFileParts = normalizedReferencePath.to_s.downcase.split( '/' )
      toAddArraySize = referenceFileParts.length()
      result = 0
      referenceLine = ''

      srcfiles.each do |l|
        line = l.downcase
        path = line.match(/[$]proj_dir[$](.*)/)[1]
        path = projectdirectory + '/' + path
        normalizedPath = Pathname.new(path).cleanpath
        srcProjectFileParts = normalizedPath.to_s.downcase.split('/');
      
        existingAraySize = srcProjectFileParts.length()
            
        size = [].push(existingAraySize).push(toAddArraySize).max()

        i = 0;
        for i in 1..size
            if srcProjectFileParts[i] != referenceFileParts[i]
                break
            end
        end
        if i != 0
            i = i -1
        end

        if i >= expectedclosenesslevel
          # first match of file with requried closeness level
          referenceLine = l
          srcfileLine = build_src_file_line_by_template(srcfile: referencefile, templatefile: referenceLine)
          insert_src_file_line_above_reference(srcfileLine: srcfileLine, referenceLine: referenceLine)
          break
        end
      end
    end

    def calculate_closeness_level(referencefile: '') 
        normalizedReferencePath = Pathname.new(referencefile).cleanpath
        referenceFileParts = normalizedReferencePath.to_s.downcase.split( '/' )
        toAddArraySize = referenceFileParts.length()
        result = 0
        srcfiles.each do |l|
          line = l.downcase
          path = line.match(/[$]proj_dir[$](.*)/)[1]
          path = projectdirectory + '/' + path
          normalizedPath = Pathname.new(path).cleanpath
          srcProjectFileParts = normalizedPath.to_s.downcase.split('/');
        
          existingAraySize = srcProjectFileParts.length()
              
          size = [].push(existingAraySize).push(toAddArraySize).max()

          i = 0;
          for i in 1..size
              if srcProjectFileParts[i] != referenceFileParts[i]
                  break
              end
          end
          if i != 0
              i = i -1
          end

          if i>result
            result = i
          end

        end

        return result
   
    end

    private

    def read_data_from_file
      isFileBlockStarted = false
      isLineCaptured = false

      f=File.open(filepath, 'r')

      f.each do |l|            
          line = l.downcase
          if line =~ /<file>/
              isFileBlockStarted = true
          else
              if isFileBlockStarted == true
                  path = line.match(/<name>(.*)<\/name>/)
                  unless path == nil
                    line = path[1]
                    if (line =~ /[.]c|h/)   #somehow not only c and h files match                  
                      if line[-1] == 'c'
                        srcfiles.push(l)                      
                      elsif line[-1] == 'h'
                        headerfiles.push(l)
                      else
                        asmfiles.push(l) 
                      end
                        isLineCaptured = true
                    end                    
                  else
                      isFileBlockStarted = false
                  end
              end
          end    
          if isLineCaptured == true
              if line =~ /<\/file>/
                  isLineCaptured = false
                  isFileBlockStarted = false
              end
          end
      end
      f.close
    end

    def build_src_file_line_by_template(srcfile: '', templatefile: '')
        normalizedSrcFilePath = srcfile.split('/').join('\\')
        resultLine = ''
        srcFilePathElements = normalizedSrcFilePath.split('\\')
        srcFilePathElements.each do |element|
            templateParts = templatefile.split(element)
            if templateParts.length == 2
                resultLine = templateParts[0] + element + normalizedSrcFilePath.split(element)[1] + '</name>'
                break
            end
        end
        return resultLine
    end

    def insert_src_file_line_above_reference(srcfileLine: '', referenceLine: '')
      File.chmod(0604, filepath) # files could be read only by default
      lines = File.readlines(filepath)
      if i = lines.index(referenceLine)
        requiredSpaces = srcfileLine.split('<name>')[0]
        requiredSpaces = requiredSpaces[0..-3]
        lines.insert(i+1, requiredSpaces.to_s + '</file>'.to_s+$/) 
        lines.insert(i+2, requiredSpaces.to_s + '<file>'.to_s+$/) 
        lines.insert(i+3, srcfileLine.to_s+$/) 
        File.open(filepath, 'w+b') { |file| file.write(lines.join) }
      end
    end
end