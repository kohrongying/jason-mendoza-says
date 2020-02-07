record Data {
  quote : String
}

enum Status {
  Initial
  Loading
  Error(String)
  Ok(Data)
}

store Quotes {
  state status : Status = Status::Initial
  state id : Number = 1
  state max : Number = 77

  fun load : Promise(Never, Void) {
    sequence {
      next { status = Status::Loading }

      next { id = Array.sample(Array.range(1, max)) |> Maybe.withDefault(1) }

      response = 
        "https://cors-anywhere.herokuapp.com/https://jsonbase.com/dIvRREdwzsIJ05DOsUt1ImStp3Gr8LR8/#{id}"
        |> Http.get()
        |> Http.send()

      object = response.body
        |> Json.parse()
        |> Maybe.toResult("")
      
      decodedResults = 
        decode object as Data
      
      next { status = Status::Ok(decodedResults) }
    } catch Http.ErrorResponse => error {
      next { status = Status::Error("Something went wrong") }
    } catch Object.Error => error {
      next { status = Status::Error("Data is not expected") }
    } catch String => error {
      next { status = Status::Error("Invalid JSON data") }
    }
  }
}

routes {
  * {
    Quotes.load()
  }
}

component Main {
  connect Quotes exposing { status }

  style base {
    font-family: sans-serif;
    overflow: hidden;
    height: 97vh;
  }
  style title {
    width: 100vw;
    height: 60%;
    background-color: #F8BD1B;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    display: flex;
  }
  style header {
    margin-bottom: 0;
    color: #2562A1;
    font-size: 60px;
  }
  style subheader {
    margin-top: 10px;
    color: #2562A1;
    letter-spacing: 2px;
  }

  style content {
    height: 40%;
    justify-content: center;
    display: flex;
    position: relative;
  }
  style quote-container{
    background-color: white;
    position: absolute;
    top: -42px;
    border-radius: 50px;
    width: 60%;
  }
  style quote {
    text-align: center;
    padding: 30px 80px;
    line-height: 2;
  }
  style button {
    padding: 10px 20px;
    font-size: 12px;
    border-radius: 8px;
    box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.16), 0 0 0 1px rgba(0, 0, 0, 0.08);
    margin-top: 30px;
    background-color: transparent;
    border: 2px solid #2562A1;
    color: #2562A1;

    &:hover {
      background-color: #2562A1;
      color: white;
      transition: 0.5s all;
    }
  }

  fun render : Html {
    <div::base>
      <section::title>
        <h1::header>"The Good Place"</h1>
        <h3::subheader>"WITH JASON MENDOZA"</h3>
        <button::button
          onClick={(event : Html.Event) : Promise(Never,Void) {
            Quotes.load()
          }}>
          "SHOW ME ANOTHER"
        </button>
      </section>

      <section::content>

        <div::quote-container>
          case (status) {
            Status::Initial => <div></div>
            Status::Loading => <div></div>
            Status::Error message => <div><{ message }></div>
            Status::Ok data => 
                <p::quote><{ data.quote }></p>
          }
        </div>
      </section>
    </div>
  }
}