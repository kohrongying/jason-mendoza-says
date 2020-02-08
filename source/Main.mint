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
  }
  style title {
    width: 100vw;
    background-color: #F8BD1B;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    display: flex;

    & h1 {
      margin-bottom: 0;
      color: #2562A1;
      font-size: 60px;
      text-align: center;
    }

    & h3 {
      margin-top: 10px;
      color: #2562A1;
      letter-spacing: 2px;
    }
  }

  style content {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    align-items: center;
    padding: 30px;
    position: relative;

    & div {
      background-color: white;
      border-radius: 50px;
      width: 60%;
      margin-bottom: 50px;
      padding: 10px 30px;

      &:before { 
        content: " ";
        position: absolute;
        width: 100vw;
        left: 0;
        top: -2px;
        background-color: #F8BD1B;
        height: 100px;
        z-index: -1;
      }
      @media (max-width: 600px) {
        width: 80%;
      }

      & p {
        text-align: center;
        font-size: 28px;
        line-height: 1.5;

        @media (max-width: 600px) {
          font-size: 22px;
        }
      }
    }

    & span {
      color: white;

      & a { 
        color: white;
      }
    }

  }
  style button {
    padding: 10px 20px;
    font-size: 14px;
    border-radius: 8px;
    box-shadow: 0 2px 2px 0 rgba(0, 0, 0, 0.16), 0 0 0 1px rgba(0, 0, 0, 0.08);
    margin: 30px;
    background-color: transparent;
    border: 2px solid #2562A1;
    color: #2562A1;

    &:hover {
      background-color: #2562A1;
      color: white;
      transition: 0.5s all;
      cursor: pointer;
    }
  }

  fun render : Html {
    <div::base>
      <section::title>
        <h1>"The Good Place"</h1>
        <h3>"WITH JASON MENDOZA"</h3>
        <button::button
          onClick={(event : Html.Event) : Promise(Never,Void) {
            Quotes.load()
          }}>
          "SHOW ME ANOTHER"
        </button>
      </section>

      <section::content>
        <div>
          case (status) {
            Status::Initial => <div></div>
            Status::Loading => <p><i>"GO BORTLES!"</i></p>
            Status::Error message => <p><{ message }></p>
            Status::Ok data => 
                <p><{ data.quote }></p>
          }
        </div>
        <span>
          "Built with "
          <a target="_blank" href="https://www.mint-lang.com/">
            "mint-lang"
          </a>
          " | "
          <a target="_blank" href="https://github.com/kohrongying/jason-mendoza-says">
            "Github"
          </a>
        </span>
      </section>
    </div>
  }
}