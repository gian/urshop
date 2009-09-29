con colMeta = fn t :: Type =>
                 {Nam : string,
                  Show : t -> xbody}
con colsMeta = fn cols :: {Type} => $(map colMeta cols)

val prodName : string -> colMeta string
val prodDesc : string -> colMeta string
val prodPrice : string -> colMeta float
val prodStock : string -> colMeta int
val prodAttr : string -> colMeta string

functor Make(M : sig
                 con cols :: {Type}
                 constraint [Id] ~ cols
                 val fl : folder cols

                 table tab : ([Id = int] ++ cols)

                 val cols : colsMeta cols

				 val cartAdd : int -> transaction page

				 val display_container : css_class
             end) : sig
    val displayProd : int -> transaction xbody 
    val displayProds : unit -> transaction page
end
