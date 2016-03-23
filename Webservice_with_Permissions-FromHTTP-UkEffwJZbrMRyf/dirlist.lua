

function ListLocal(R,A)
   local R ={}
   for K,V in os.fs.glob(os.getenv('HOME')..'/*') do
      R[K] = V.isdir
   end
   
   net.http.respond{body=json.serialize{data=R}, entity_type='text/json'}
end