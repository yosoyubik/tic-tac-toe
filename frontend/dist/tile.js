const _jsxFileName = "/Users/jose/Dropbox/urbit/toe/template/tile/tile.js";import React, { Component } from 'react';
import classnames from 'classnames';
import _ from 'lodash';
import { sigil, reactRenderer } from 'urbit-sigil-js'


const Sigil = props => {
 return (
   React.createElement('div', {__self: this, __source: {fileName: _jsxFileName, lineNumber: 9}}
   , 
     sigil({
       patp: props.patp,
       renderer: reactRenderer,
       size: 30,
       colors: [props.colorF, props.colorB],
     })
   
   )
 )
}

function Square(props) {
  return (
    React.createElement('button', { className: "square", onClick: props.onClick, style: {width: 40, height: 40}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 24}}
      , props.value
    )
  );
}

class Board extends React.Component {
  renderSquare(i, j) {
    return (
      React.createElement(Square, {
        value: this.props.squares[i][j],
        onClick: () => this.props.onClick([i, j]), __self: this, __source: {fileName: _jsxFileName, lineNumber: 33}}
      )
    );
  }

  render() {
    return (
      React.createElement('div', {__self: this, __source: {fileName: _jsxFileName, lineNumber: 42}}
        , React.createElement('div', { className: "board-row", __self: this, __source: {fileName: _jsxFileName, lineNumber: 43}}
          , this.renderSquare(0, 0)
          , this.renderSquare(0, 1)
          , this.renderSquare(0, 2)
        )
        , React.createElement('div', { className: "board-row", __self: this, __source: {fileName: _jsxFileName, lineNumber: 48}}
          , this.renderSquare(1, 0)
          , this.renderSquare(1, 1)
          , this.renderSquare(1, 2)
        )
        , React.createElement('div', { className: "board-row", __self: this, __source: {fileName: _jsxFileName, lineNumber: 53}}
          , this.renderSquare(2, 0)
          , this.renderSquare(2, 1)
          , this.renderSquare(2, 2)
        )
      )
    );
  }
}

class Message extends React.Component {
  render() {
    return(
      React.createElement('div', { className: "flex absolute" , style: {left: 35, bottom: 15, width: "86%"}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 66}}
        , React.createElement('p', {
          className: "label small dib yellow"   ,
          style: {left: 8}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 67}}
          , this.props.mssg)
      )
  )}

}

// Playing(prop) {
//   return (
//       <div className="w-100 mb2 mt2 absolute"
//         style={{left: 8}}>
//       <p
//         className="label small dib blue"
//         style={{left: 8}}>
//         {ship}</p>
//       vs
//       <p
//         className="label small dib red"
//         style={{left: 8}}>
//         {props.data}</p>
//     </div>
//   )
// }

class Confirmation extends React.Component {
  confirmGame(e) {
    e.preventDefault();
    this.props.confirm();
  }

  rejectGame(e) {
    e.preventDefault();
    this.props.reject();
  }

  render() {
    return (
      React.createElement('div', { className: "flex absolute" , style: {left: 10, bottom: 5, width: "86%"}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 106}}

         , React.createElement('p', { className: "label small zdib yellow"   , __self: this, __source: {fileName: _jsxFileName, lineNumber: 108}}, "play with "
              , this.props.mssg, "?"
        )
         , React.createElement('button', { className: "f6 no-underline br-pill ba ph3 b--white pv2 mb2 fade dim black"          ,
            onClick: this.confirmGame.bind(this), __self: this, __source: {fileName: _jsxFileName, lineNumber: 111}}, "Y"

         )
         , React.createElement('button', { className: "f6 no-underline br-pill ba ph3 b--white pv2 mb2 fade dim black"          ,
            onClick: this.rejectGame.bind(this), __self: this, __source: {fileName: _jsxFileName, lineNumber: 115}}, "N"

         )
       )
    )
  }

}


class ChooseOpponent extends React.Component {

  keyPress(e) {
    if (e.keyCode === 13) {
      e.preventDefault();
      this.props.send(e.target.value);
    }
  }

  render() {
    return(
      React.createElement('form', { className: "flex absolute" , style: {left: 30, bottom: 0}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 137}}
        , React.createElement('input', { id: "opponent",
          className: "white pa1 bg-transparent outline-0 bn bb-ns b--white"      ,
          style: {width: "86%"},
          type: "text",
          placeholder: "enter @p (e.g. ~zod)"   ,
          onKeyDown: this.keyPress.bind(this), __self: this, __source: {fileName: _jsxFileName, lineNumber: 138}}
        )
      )
    )
  }
}

export default class toeTile extends Component {

  constructor(props) {
    super(props);

    let ship = window.ship;
    let api = window.api;
    let store = window.store;

    this.state = {
      opponent: null,
      subscribers: [],
      error: false,
      squares: Array(3).fill(Array(3).fill(null)),
      stepNumber: 0,
      amNext: false,
      winner: null,
      message: "",
      stone: null,
      game: null
    };
  }

  sendOpponent(opponentShip) {
    // this.setState({opponent: opponentShip});
    api.action('toe', 'json', {'data': opponentShip});
  }

  confirmGame() {
    console.log('we confirm!');
    api.action('toe', 'json', {'data': 'y'});
  }

  rejectGame() {
    console.log('we confirm!');
    api.action('toe', 'json', {'data': 'n'});
  }

  handleClick(spot) {
    console.log(spot, this.state.amNext);
    if (this.state.amNext) {
      const squares = this.state.squares.slice();
      console.log(spot, squares, squares[spot[0]][spot[1]])
      squares[spot[0]][spot[1]] = this.state.stone;
      api.action('toe', 'json', {'data': [++spot[0], ++spot[1]]});
      this.setState({
        squares: squares,
        amNext: !this.state.amNext
      });
    }
  }

  renderWrapper(child) {
    return (
      React.createElement('div', { className: "pa2 relative" , style: {
        width: 234,
        height: 234,
        background: '#1a1a1a'
      }, __self: this, __source: {fileName: _jsxFileName, lineNumber: 204}}
        , child
      )
    );
  }

  gameStatus(status, message) {
    let bottomText;
    console.log(status);
    switch(status) {
      case 'select-opponent':
        this.setState({opponent: message});
        this.setState({stone: 'O'});
        bottomText = React.createElement(Messages, { mssg: message, __self: this, __source: {fileName: _jsxFileName, lineNumber: 221}});
        break;
      case 'confirm':
        this.setState({opponent: message});
        this.setState({stone: 'X'});
        bottomText = React.createElement(Confirmation, { mssg: message, status: status, __self: this, __source: {fileName: _jsxFileName, lineNumber: 226}});
        break;
      case 'start':
        //placeMoveOnBoard(data.message);
        if (data === ship){
          this.setState({amNext: true});
        } else {
          this.setState({amNext: false});
        }
        bottomText = React.createElement(Playing, { data: message, __self: this, __source: {fileName: _jsxFileName, lineNumber: 235}});
        break;
      case 'replay':
        bottomText = React.createElement(Confirmation, { mssg: message, status: status, __self: this, __source: {fileName: _jsxFileName, lineNumber: 238}});
        break;
      case 'error':
        console.log(message);
        break;
      default:
        if (this.state.opponent) {
          bottomText = React.createElement(Messages, { mssg: message, __self: this, __source: {fileName: _jsxFileName, lineNumber: 245}});
        } else {
          bottomText = React.createElement(ChooseOpponent, { send: this.sendOpponent.bind(this), __self: this, __source: {fileName: _jsxFileName, lineNumber: 247}} );
        }
    }
    console.log(bottomText);
    return bottomText;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    const data = !!this.props.data ? this.props.data : {};
    const squares = this.state.squares.slice();
    let amNext = this.state.amNext;
    let opponent = this.state.opponent;
    let stone = this.state.stone;
    if (data === null) {
      // We reset state
      this.setState({
        opponent: null,
        subscribers: [],
        error: false,
        squares: Array(3).fill(Array(3).fill(null)),
        stepNumber: 0,
        amNext: false,
        winner: null,
        message: "",
        stone: null,
        game: null
      });
    }
    // Typical usage (don't forget to compare props):
    else if (snapshot !== null) {
      if (data !== prevProps.data) {
        // We receive a diff from %toe
        console.log("something changed!");
        if (data.status === "start") {
          amNext = (data.current.replace('~', '') === ship);
          console.log("starts!", data.current.replace('~', ''), ship, amNext);
          stone = data.stone
        }
        if ((data.status === "select-opponent") || (data.status === "confirm")) {
          opponent = data.message;
        }
        if (data.status === "play") {
          amNext = !amNext;
          opponent = data.data;
          if ('move' in data) {
            squares[--data.move[0]][--data.move[1]] = data.stone;
          }
        }
        if ('status' in data) {
          if (data.status != "error") {
            this.setState({
              game: data.status,
              message: data.data,
              amNext: amNext,
              opponent: opponent,
              stone: stone,
              squares: squares
            });
          } else {
            this.setState({
              error: !data.error,
              message: data.data
            });
          }
        }
      }
    }
  }

  render() {
    let data = !!this.props.data ? this.props.data : {};
    let bottomElement;
    console.log("rendering", this.props.data);

    const squares = this.state.squares;
    const opponent = this.state.opponent;
    const game = this.state.game;
    const message = this.state.message;
    const error = this.state.error;
    // const current = history[this.state.stepNumber];
    // let bottomText = this.gameStatus(data.status, data.message);

    return this.renderWrapper((
      React.createElement('div', {__self: this, __source: {fileName: _jsxFileName, lineNumber: 330}}
          , React.createElement('p', { className: "gray label-regular b absolute"   ,
            style: {left: 8, top: 4}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 331}}, "Tic-Tac-Toe"

          )
          , React.createElement('a', { className: "label-regular b gray absolute pointer"    ,
            style: {right: 8, top: 4},
            onClick: () => this.setState({manualEntry: !this.state.manualEntry}), __self: this, __source: {fileName: _jsxFileName, lineNumber: 335}}, "Preferences ->" )

          , React.createElement('div', { className: "game", __self: this, __source: {fileName: _jsxFileName, lineNumber: 339}}
            , error ? React.createElement(Message, { mssg: message, __self: this, __source: {fileName: _jsxFileName, lineNumber: 340}} ) : null 
            , React.createElement('div', { className: "w-100 h-100 absolute"  , style: {left: 30, top: 73}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 341}}
              , React.createElement(Sigil, { patp: ship, colorF: "white", colorB: "black", __self: this, __source: {fileName: _jsxFileName, lineNumber: 342}} )
              , React.createElement('p', { className: "label-regular b gray "   , style: {left: 27}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 343}}, "vs")
              ,  game === 'start' ? React.createElement(Sigil, { patp: opponent, colorF: "white", colorB: "black", __self: this, __source: {fileName: _jsxFileName, lineNumber: 344}} ) : null 
            )
            , React.createElement('div', { className: "w-100 h-100 absolute"  , style: {left: 90, top: 55}, __self: this, __source: {fileName: _jsxFileName, lineNumber: 346}}
              , React.createElement(Board, {
                squares: this.state.squares,
                onClick: spot => this.handleClick(spot), __self: this, __source: {fileName: _jsxFileName, lineNumber: 347}}
              )
            )
            , (game === null) ? React.createElement(ChooseOpponent, { send: this.sendOpponent.bind(this), __self: this, __source: {fileName: _jsxFileName, lineNumber: 352}} ) : null 
            , (game === 'select-opponent') ? React.createElement(Message, { mssg: "...waiting for ".concat(opponent), __self: this, __source: {fileName: _jsxFileName, lineNumber: 353}} ) : null 
            , (game === 'confirm') ? React.createElement(Confirmation, { mssg: opponent, status: status, confirm: this.confirmGame.bind(this), reject: this.rejectGame.bind(this), __self: this, __source: {fileName: _jsxFileName, lineNumber: 354}}) : null 
            , (game === 'start') ? React.createElement(Message, { mssg: "The game begins!", __self: this, __source: {fileName: _jsxFileName, lineNumber: 355}} ) : null 
          ), "// "
           , (game === 'replay') ? React.createElement(Confirmation, { mssg: message, status: status, __self: this, __source: {fileName: _jsxFileName, lineNumber: 357}}) : null 
      )
    ));

  }

}

window.toeTile = toeTile;
