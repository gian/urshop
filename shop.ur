(* Copyright (c) 2009 Gian Perrone
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
 *)

table product : { Id : int, Title : string, EAN : string, Price : float, Stock : int }
	PRIMARY KEY Id

table order : { Id : int, FirstName : string, LastName : string, Address1 : string, Address2 : string, City : string, Country : string, PostCode : string, Created : time, Status : string}
	PRIMARY KEY Id,

table orderline : { Id : int, OrderId : int, ProductId : int, Price : float, Qty : int }
	PRIMARY KEY Id,
	CONSTRAINT OrderId FOREIGN KEY OrderId REFERENCES order(Id),
	CONSTRAINT ProductId FOREIGN KEY ProductId REFERENCES product(Id)

table category : { Id : int, Title : string, Description : string, Parent : int }
	PRIMARY KEY Id

table productCategory : { CategoryId : int, ProductId : int }
	CONSTRAINT CategoryId FOREIGN KEY CategoryId REFERENCES category(Id),
	CONSTRAINT ProductId FOREIGN KEY ProductId REFERENCES product(Id)

sequence orderS
sequence orderlineS

style display_container
style buybutton

cookie cartCookie : list int

val formatting = {Head =
					fn title => <xml><head><title>{[title]}</title>
					 <link rel="stylesheet" type="text/css" href="http://www.expdev.net/urshop/urshop.css"/>
					</head></xml>
					, BodyStart = 
					fn title => <xml><h1>{[title]}</h1></xml>
					, BodyEnd =
					fn () => <xml><p>This is a footer</p></xml>}

open Product.Make(struct
                 val tab = product

                 val cols = {
					Title = Product.prodName "Title",
					Price = Product.prodPrice "Price",
					EAN = Product.prodAttr "EAN",
					Stock = Product.prodStock "Stock"
				 }

				 val display_container = display_container

				 val formatting = formatting

				 val cartCookie = cartCookie
             end) 

fun categoryList (catId : int) = 
	cl <- queryX' (SELECT * FROM productCategory WHERE productCategory.CategoryId = {[catId]})
		(fn r => <xml>{displayProd r.ProductCategory.ProductId True}</xml>);
	catDet <- oneRow (SELECT * FROM category WHERE Category.Id = {[catId]});
	return <xml>{formatting.Head catDet.Category.Title}
				<body><h1>{[catDet.Category.Title]}</h1>
					<p>{[catDet.Category.Description]}</p>
					{cl}
				</body>
			</xml>

fun main () =
	return <xml>{formatting.Head "UrShop"}<body><h1>UrShop</h1><a link={categoryList 1}>Display Product</a></body></xml>

