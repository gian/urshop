(* Copyright (c) 2008, Adam Chlipala
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - The names of contributors may not be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * Modified September 2009 by Gian Perrone for use with Urblog from
 * Ur/Web 'Crud' example at:
 * http://www.impredicative.com/ur/demo/
 *)

style display_title
style display_desc
style display_price
style display_stock
style display_nostock
style display_attr

con colMeta = fn t :: Type =>
                 {Nam : string,
                  Show : t -> xbody}
con colsMeta = fn cols :: {Type} => $(map colMeta cols)

fun prodName name = {Nam = name,
					 Show = fn x => <xml><h2 class={display_title}>{[x]}</h2></xml>}

fun prodDesc name = {Nam = name,
					 Show = fn x => <xml><h3>About this product:</h3><p class={display_desc}>{[x]}</p></xml>}

fun prodPrice name =  {Nam = name,
					 Show = fn x => <xml><p class={display_price}>Our Price: ${[x]}</p></xml>}

fun prodStock name = {Nam = name,
					 Show = fn x => if x > 0 then <xml><p class={display_stock}>{[x]} in stock</p></xml> else 
												  <xml><p class={display_nostock}>Out of stock</p></xml>}
fun prodAttr name = {Nam = name,
					 Show = fn x => <xml><li class={display_attr}>{[name]}: {[x]}</li></xml>}

functor Make(M : sig
                 con cols :: {Type}
                 constraint [Id] ~ cols
                 val fl : folder cols

                 table tab : ([Id = int] ++ cols)

                 val cols : colsMeta cols
	
				 cookie cartCookie : list int

				 val formatting : {Head : string -> page, BodyStart : string -> xbody, BodyEnd : unit -> xbody}

				 val display_container : css_class
             end) = struct

    val tab = M.tab
	val display_container = M.display_container
	val cartCookie = M.cartCookie
	val formatting = M.formatting

	fun displayProds () =
	 rows <- queryX (SELECT * FROM tab AS T)
	    (fn (fs : {T : $([Id = int] ++ M.cols)}) => <xml>
		{foldRX2 [id] [colMeta] [body]
              (fn [nm :: Name] [t :: Type] [rest :: {Type}]
                      [[nm] ~ rest] v col => <xml>
                                               {col.Show v}
                                             </xml>)
                      [M.cols] M.fl (fs.T -- #Id) M.cols}
 	    </xml>);
	 return <xml><body>{rows}</body></xml>

	fun displayProd (id : int) =
	 rows <- queryX (SELECT * FROM tab AS T WHERE T.Id = {[id]})
	    (fn (fs : {T : $([Id = int] ++ M.cols)}) => <xml>
		<div class={M.display_container}>{foldRX2 [id] [colMeta] [body]
              (fn [nm :: Name] [t :: Type] [rest :: {Type}]
                      [[nm] ~ rest] v col => <xml>
                                               {col.Show v}
                                             </xml>)
                      [M.cols] M.fl (fs.T -- #Id) M.cols}
 	    <a link={cartAdd id}>Add to Cart</a></div></xml>);
	return <xml>{rows}</xml>

	(* return <xml>{displayProd i}</xml>) items); *)

	and cart () = 
		c <- getCookie cartCookie;
		(case c of None => return <xml>{formatting.Head "Cart"}<body>{formatting.BodyStart "Cart"}<p>Your cart is empty</p>{formatting.BodyEnd ()}</body></xml>
	              | Some items =>
				  	dp <- List.mapXM displayProd items;
				  	return <xml>{formatting.Head "Cart"}<body>{formatting.BodyStart "Cart"}
						{dp}
						{formatting.BodyEnd ()}</body>
					</xml>	
		)

	and cartAdd (id : int) = 
		c <- getCookie cartCookie;
		(case c of
			None => setCookie cartCookie (Cons (id, Nil)); cart ()
		  | Some x => if (List.exists (fn y => y = id) x) then cart() else setCookie cartCookie (Cons (id, x)); cart ())

end
