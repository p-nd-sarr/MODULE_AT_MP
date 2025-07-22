class String
  def format_with_space(*args)
    str = ''
    nombre_caractere = 0
    args.each do |n|
      seq = self[nombre_caractere..nombre_caractere + n - 1]
      str += seq + ' ' unless seq.nil?
      nombre_caractere += n
    end
    str.strip
  end
end