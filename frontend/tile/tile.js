import React, { Component } from 'react';
import classnames from 'classnames';
import _ from 'lodash';
import { sigil, reactRenderer } from 'urbit-sigil-js'


const Sigil = props => {
 return (
   <div>
   {
     sigil({
       patp: props.patp,
       renderer: reactRenderer,
       size: 30,
       colors: [props.colorF, props.colorB],
     })
   }
   </div>
 )
}

function Square(props) {
  return (
    <button className="square" onClick={props.onClick} style={{width: 40, height: 40}}>
      {props.value}
    </button>
  );
}

class Board extends React.Component {
  renderSquare(i, j) {
    return (
      <Square
        value={this.props.squares[i][j]}
        onClick={() => this.props.onClick([i, j])}
      />
    );
  }

  render() {
    return (
      <div>
        <div className="board-row">
          {this.renderSquare(0, 0)}
          {this.renderSquare(0, 1)}
          {this.renderSquare(0, 2)}
        </div>
        <div className="board-row">
          {this.renderSquare(1, 0)}
          {this.renderSquare(1, 1)}
          {this.renderSquare(1, 2)}
        </div>
        <div className="board-row">
          {this.renderSquare(2, 0)}
          {this.renderSquare(2, 1)}
          {this.renderSquare(2, 2)}
        </div>
      </div>
    );
  }
}

class Message extends React.Component {
  render() {
    return(
      <div className="flex absolute" style={{left: 35, bottom: 15, width: "86%"}}>
        <p
          className="label small dib yellow"
          style={{left: 8}}>
          {this.props.mssg}</p>
      </div>
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
      <div className="flex absolute" style={{left: 10, bottom: 5, width: "86%"}}>

         <p className="label small zdib yellow">
            play with {this.props.mssg}?
        </p>
         <button className="f6 no-underline br-pill ba ph3 b--white pv2 mb2 fade dim black"
            onClick={this.confirmGame.bind(this)}>
            Y
         </button>
         <button className="f6 no-underline br-pill ba ph3 b--white pv2 mb2 fade dim black"
            onClick={this.rejectGame.bind(this)}>
            N
         </button>
       </div>
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
      <form className="flex absolute" style={{left: 30, bottom: 0}}>
        <input id="opponent"
          className="white pa1 bg-transparent outline-0 bn bb-ns b--white"
          style={{width: "86%"}}
          type="text"
          placeholder="enter @p (e.g. ~zod)"
          onKeyDown={this.keyPress.bind(this)}>
        </input>
      </form>
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
      <div className="pa2 relative" style={{
        width: 234,
        height: 234,
        background: '#1a1a1a'
      }}>
        {child}
      </div>
    );
  }

  gameStatus(status, message) {
    let bottomText;
    console.log(status);
    switch(status) {
      case 'select-opponent':
        this.setState({opponent: message});
        this.setState({stone: 'O'});
        bottomText = <Messages mssg={message}/>;
        break;
      case 'confirm':
        this.setState({opponent: message});
        this.setState({stone: 'X'});
        bottomText = <Confirmation mssg={message} status={status}/>;
        break;
      case 'start':
        //placeMoveOnBoard(data.message);
        if (data === ship){
          this.setState({amNext: true});
        } else {
          this.setState({amNext: false});
        }
        bottomText = <Playing data={message}/>;
        break;
      case 'replay':
        bottomText = <Confirmation mssg={message} status={status}/>;
        break;
      case 'error':
        console.log(message);
        break;
      default:
        if (this.state.opponent) {
          bottomText = <Messages mssg={message}/>;
        } else {
          bottomText = <ChooseOpponent send={this.sendOpponent.bind(this)} />;
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
      <div>
          <p className="gray label-regular b absolute"
            style={{left: 8, top: 4}}>
            Tic-Tac-Toe
          </p>
          <a className="label-regular b gray absolute pointer"
            style={{right: 8, top: 4}}
            onClick={() => this.setState({manualEntry: !this.state.manualEntry})}>Preferences -></a>

          <div className="game">
            {error ? <Message mssg={message} /> : null }
            <div className="w-100 h-100 absolute" style={{left: 30, top: 73}}>
              <Sigil patp={ship} colorF='white' colorB='black' />
              <p className="label-regular b gray " style={{left: 27}}>vs</p>
              { game === 'start' ? <Sigil patp={opponent} colorF='white' colorB='black' /> : null }
            </div>
            <div className="w-100 h-100 absolute" style={{left: 90, top: 55}}>
              <Board
                squares={this.state.squares}
                onClick={spot => this.handleClick(spot)}
              />
            </div>
            {(game === null) ? <ChooseOpponent send={this.sendOpponent.bind(this)} /> : null }
            {(game === 'select-opponent') ? <Message mssg={"...waiting for ".concat(opponent)} /> : null }
            {(game === 'confirm') ? <Confirmation mssg={opponent} status={status} confirm={this.confirmGame.bind(this)} reject={this.rejectGame.bind(this)}/> : null }
            {(game === 'start') ? <Message mssg={"The game begins!"} /> : null }
          </div>
          // {(game === 'replay') ? <Confirmation mssg={message} status={status}/> : null }
      </div>
    ));

  }

}

window.toeTile = toeTile;
