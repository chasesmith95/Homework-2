pragma solidity ^0.4.15;

contract Betting {
	/* Standard state variables */
	address owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {require(msg.sender != owner); _;}
	modifier OracleOnly() {require(msg.sender != oracle); _;}
	modifier ValidBettor() {require(msg.sender != gamblerA); require(msg.sender != gamblerB); _;}

	/* Constructor function, where owner and outcomes are set */
	function Betting(uint[] _outcomes) {
		outcomes = _outcomes;
		owner = msg.sender;
	}

	function getOwner() constant returns (address) {
		return owner;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		oracle = _oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) ValidBettor() payable returns (bool) {
		// check for valid outcome
		bool correct = false;
		for (uint i = 0; i < outcomes.length; i++) {
				if (outcomes[i] == _outcome) { correct = true; }
    }

		bets[msg.sender] = Bet({outcome: _outcome, amount: msg.value, initialized: correct});
		BetMade(msg.sender);

	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
			//create a list of all those people that are right
			if (bets[gamblerA].outcome == bets[gamblerB].outcome) {
				//refund and return
				winnings[gamblerA] = bets[gamblerA].amount;
				winnings[gamblerB] = bets[gamblerB].amount;
			} else {
				if (bets[gamblerA].outcome == _outcome) {
					winnings[gamblerA] = bets[gamblerB].amount + bets[gamblerA].amount;
				}
				if (bets[gamblerB].outcome == _outcome) {
					winnings[gamblerB] = bets[gamblerB].amount + bets[gamblerA].amount;
				}
		 }
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		if (checkWinnings() >= withdrawAmount) {
			winnings[msg.sender] -= withdrawAmount;
			msg.sender.transfer(withdrawAmount);
		}
		return checkWinnings();
	}

	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
		return outcomes;
	}

	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
		return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		delete(bets[gamblerA]);
		delete(bets[gamblerB]);
		delete(gamblerA);
		delete(gamblerB);

	}

	/* Fallback function */
	function() payable {
		revert();
	}
}
